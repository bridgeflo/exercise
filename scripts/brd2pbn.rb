# ********************************************************************************
# brd2pbn.rb
#                                                                                 
# ********************************************************************************
unless ARGV.length == 1 
  puts "Usage: brd2pbn.rb pattern"
  exit
end

def scrape_deals(html)
  whole_list_matches = %r{</colgroup>.*</table></td></tr>}m
  one_element_matches = %r{<td.*?>[0-9AKDB-]+</td>}m

  html_list = html[whole_list_matches]
  suit=html_list.scan(one_element_matches).collect do | item |
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
    def initialize(dat,pattern)
        html = File.open(dat).read
        suit = scrape_deals(html)
        @deal = suit[0..15]
        dat =~/^#{pattern}(\d+)\.html/
        @brd = $1
    end
    def to_s
        msg = ''
        msg +=  "\[Board \"#{@brd}\"\]\n"
        msg +=  "\[Dealer \"#{TEILER[@brd.to_i%4]}\"\]\n"
        msg +=  "\[Vulnerable \"#{GEFAHR[@brd.to_i%16]}\"\]\n"
        msg +=  "\[Deal \"N:#{@deal[0]}.#{@deal[1]}.#{@deal[2]}.#{@deal[3]} #{@deal[5]}.#{@deal[7]}.#{@deal[9]}.#{@deal[11]} #{@deal[12]}.#{@deal[13]}.#{@deal[14]}.#{@deal[15]} #{@deal[4]}.#{@deal[6]}.#{@deal[8]}.#{@deal[10]}\"\]\n"
        msg
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
						@contracts << "#{p_ns}\t#{p_ew}\t#{pos}\t#{denom}#{suit}#{result}\t#{score}\n" 
					end					
				end		
								
			end
        end
	end
    def to_s
        msg = "\[ContractTable \"Pair_NS;Pair_EW;Declarer;Contract;Score_NS\"\]\n"
		@contracts.each do | line |
			msg += line
		end
        msg
    end
end

if $0 == __FILE__
    pattern = ARGV[0]
    Dir["#{pattern}*.html"].each do |dat| 
        puts PbnDeal.new(dat,pattern)
        puts ScoreTable.new(dat) 
        puts ContractTable.new(dat) 
        puts ""
    end
end


