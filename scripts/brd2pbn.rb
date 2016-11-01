# ********************************************************************************
# brd2pbn.rb
#                                                                                 
# ********************************************************************************
unless ARGV.length == 3 
  puts "Usage: brd2pbn.rb pattern name datum"
  exit
end

def scrape_deals(html)
  whole_list_matches = %r{</colgroup>.*</table></td></tr>}m
  one_element_matches = %r{<td.*?>[0-9AKDB-]+</td>}m

  html_list = html[whole_list_matches]
  html_list.scan(one_element_matches).collect do | item |
    /<td.*?>([0-9AKDB-]+)<\/td>/.match(item)[1].gsub("D",'Q').gsub("B",'J').gsub("10",'T').gsub("-",'')
  end
end
class PbnDeal
    TEILER = ['W','N','E','S']
    GEFAHR = [  'EW',
                'None','NS','EW','All',
                'NS','EW','All','None',
                'EW','All','None','NS',
                'All','None','NS']
    def initialize(dat,pattern,name,datum)
      @name = name
      @datum = datum
      @pattern = pattern
      html = File.open(dat).read
      suit = scrape_deals(html)
      @deal = suit[0..15]
      dat =~ /^#{@pattern}(\d+)\.html/
      @brd = $1
    end
    def getId()
        value = @name + '-' + @datum + '-' + @pattern
        value += '0' if (@brd.to_i < 10) 
        value += @brd.to_s
        return value
    end
    def to_s
      message = '"_id" : "' + getId() + '", "nr" : ' + @brd + ', ' + "\n"
      message += "\"north\" : \{\"name\":\"north\","
      message += "\"spades\":\"#{@deal[0]}\", \"hearts\":\"#{@deal[1]}\", \"diamonds\":\"#{@deal[2]}\", \"clubs\":\"#{@deal[3]}\"\},\n"
      message += "\"east\" : \{\"name\":\"east\","
      message += "\"spades\":\"#{@deal[5]}\", \"hearts\":\"#{@deal[7]}\", \"diamonds\":\"#{@deal[9]}\", \"clubs\":\"#{@deal[11]}\"\},\n"
      message += "\"south\" : \{\"name\":\"south\","
      message += "\"spades\":\"#{@deal[12]}\", \"hearts\":\"#{@deal[13]}\", \"diamonds\":\"#{@deal[14]}\", \"clubs\":\"#{@deal[15]}\"\},\n"
      message += "\"west\" : \{\"name\":\"west\","
      message += "\"spades\":\"#{@deal[4]}\", \"hearts\":\"#{@deal[6]}\", \"diamonds\":\"#{@deal[8]}\", \"clubs\":\"#{@deal[10]}\"\},\n"
        #message += '"scores" : ['  + "\n"
        #getScores().each do |score|
        #    message += score + "\n"
        #end
        #message += ']' + "\n"
        # msg = ''
        # msg +=  "\[Board \"#{@brd}\"\]\n"
        # msg +=  "\[Dealer \"#{TEILER[@brd.to_i%4]}\"\]\n"
        # msg +=  "\[Vulnerable \"#{GEFAHR[@brd.to_i%16]}\"\]\n"
        # msg +=  "\[Deal \"N:#{@deal[0]}.#{@deal[1]}.#{@deal[2]}.#{@deal[3]} #{@deal[5]}.#{@deal[7]}.#{@deal[9]}.#{@deal[11]} #{@deal[12]}.#{@deal[13]}.#{@deal[14]}.#{@deal[15]} #{@deal[4]}.#{@deal[6]}.#{@deal[8]}.#{@deal[10]}\"\]\n"
        # msg
    end
end

class ScoreTable
    def initialize(dat)
        @scores = Array.new()
        html = File.open(dat).readlines
        html.each do |line|
            if line =~ /<td>([\d\s\&nbsp;]+)<\/td><td>([\d\s\&nbsp;]+)<\/td><td valign=bottom>/ then
                score = -$2.gsub('&nbsp;','').gsub(' ','').to_i if $1 == '&nbsp;'
                score =  $1.gsub('&nbsp;','').gsub(' ','').to_i if $2 == '&nbsp;'
                @scores << score
            end
        end
    end
    def length
        @scores.length()
    end
    def calc
        i = @scores.length
        points = Array.new
        z = 2 * (i - 1)
        i.times do 
            points << z
            z -= 2
        end
        myscores = @scores.sort{|x,y| y.to_i <=> x.to_i} 
        diffscores = Array.new
        myscores.each do |score|
            diffscores << score if not diffscores.index(score)
        end
        freq_points = Hash.new
        freq_score = Hash.new
        pos = 0
        diffscores.each do |score|
            i = "#{myscores.rindex(score)}"
            sum = 0
            z = 1 + i.to_i - pos.to_i
            z.times do 
                sum += points[pos]
                pos += 1
            end
            freq_points[score] = (sum / z)
            freq_score[score] = z
            pos = i.to_i + 1
        end
        return freq_points, freq_score
    end
    def to_s
        msg = "\[ScoreTable \"Score_NS;Multiplicity;Percentage_NS;Percentage_EW\"\]\n"
        table,freq = calc()
        top = (@scores.length - 1) * 2
        for score in table.keys.sort{|x,y| y.to_i <=> x.to_i}  do
            prozent_ns = table[score] * 100 / top.to_f
            prozent_ew = 100 - prozent_ns.to_f
            msg += "#{score}".ljust(5) + "\t" + "#{freq[score]}".rjust(3) + "\t" + sprintf("%6.2f",prozent_ns) + "\t" + sprintf("%6.2f",prozent_ew) + "\n"
        end
        msg
    end
end
class ContractTable
    def initialize(dat)
        @contracts = Array.new()
        @html = File.open(dat).readlines
        scan
    end
    def scan
         p_ns, p_ew, pos, contract, denom, suit, result, score = "", "", "", "", "", "", "", ""
          @html.each do |line|
            if line =~ /^<tr align=right valign=top>/ then			
              if line.scan(/&nbsp;<\/td>/).size == 6 then
                 # puts $1,$2 if line.scan(/<td align=left>&nbsp;(.*)&nbsp;([0-9AKDB]+)<\/td>/)			
                 pos = $1 if line.scan(/<td align=right>(.*):<\/td>/)			
                 contract = $1 if line.scan(/<td align=left>(.*)<\/td><td align=left>/)
                 if contract =~ /(\d+)\s+<font\s*color=\#[0-9abcdef]+>\&\#(\d+);<\/font>\s+(.*)/ then
                    denom = $1
                    suit = $2
                    result = $3
                    suit = "C" if suit == "9827"
                    suit = "D" if suit == "9830"
                    suit = "H" if suit == "9829"
                    suit = "S" if suit == "9824"
                 elsif contract =~ /(\d+)\s+<font\s*color=\#[0-9abcdef]+>\&\#(\d+);\s+(.*)/ then
                    denom = $1
                    suit = $2
                    result = $3
                    suit = "C" if suit == "9827"
                    suit = "D" if suit == "9830"
                    suit = "H" if suit == "9829"
                    suit = "S" if suit == "9824"
                 else
                    denom,suit,result = contract.split(' ')
                    suit = 'NT' if suit == 'SA'
                 end
                 if line =~ /<td>([\d\s\&nbsp;]+)<\/td><td>([\d\s\&nbsp;]+)<\/td><td valign=bottom>/ then
                    score = -$2.gsub('&nbsp;','').gsub(' ','').to_i if $1 == '&nbsp;'
                    score =  $1.gsub('&nbsp;','').gsub(' ','').to_i if $2 == '&nbsp;'
                 end
                 if line.scan(/p(\d+).html.*p(\d+).html/) then
                    p_ns, p_ew = $1, $2 
                    @contracts << "\"pair_ns\":\"#{p_ns}\", \"pair_ew\":\"#{p_ew}\", \"declarer\":\"#{pos}\", \"contract\":\"#{denom}#{suit}\", \"result\":\"#{result}\", \"score_ns\":\"#{score}\"" 
                 end					
              end		
            end
          end
    end
    def to_s
      message = '"scores" : ['  + "\n"
		@contracts.each do | line |
			message += '{' + line + '}' + ",\n"
		end
      message = message.chop().chop()
      message += ']' + "\n"
    end
end

if $0 == __FILE__
    pattern = ARGV[0]
    name = ARGV[1]
    datum = ARGV[2]
    output = '{ "docs": ['
    Dir["#{pattern}*.html"].each do |dat| 
      output += '{'
      output += PbnDeal.new(dat,pattern,name,datum).to_s
      # puts ScoreTable.new(dat) 
      output += ContractTable.new(dat).to_s 
      output += '},'
    end
    output = output.chop() 
    output += ']}'
    puts output
end


