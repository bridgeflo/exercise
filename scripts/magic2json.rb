# ******************************************************************************** 
# magic2pbn.rb
#
# $HeadURL: file:///Library/Subversion/repository/adalbert/jquery/trunk/fsboard/scripts/magic2json.rb $
# $Date: 2016-03-25 19:05:55 +0100 (Fr, 25 Mär 2016) $
# $Id: magic2json.rb 1023 2016-03-25 18:05:55Z mac_adalbert_mini $
#     
# extracting results from generator
# Magic Contest Oesterreich
# Version 4.4.0.1                                                                           
#
# ******************************************************************************** -->
##### encoding: UTF-8
unless ARGV.length == 1 
  puts "Usage: magic2pbn.rb html_datei"
  exit
end
class Pbn
    attr_writer  :vulnerable
    def initialize
        @frequence = {}
        @percentage_ns = {}
        @percentage_ew = {}
        @scoretable = []
        @totalscoretable = []
        @contracttable = []
        @ddsolver = []
        @identifier = "Kitzbühl"
    end
    def transform (text)
        text.to_s.gsub("---",'').gsub("10",'T').gsub("D",'Q').gsub("B",'J')
    end
    def setBoardInfo(nr, dealer, vul)
        @nr = nr
        case dealer
            when "Nord"
                @dealer="N"
            when "Ost"
                @dealer="E"
            when "West"
                @dealer="W"
            else
                @dealer="S"
        end
        case vul
            when "Keine"
                @vul="None"
            when "N-S"
                @vul="NS"
            when "O-W"
                @vul="EW"
            else
                @vul="All"
        end
    end
    def getId()
        value = ''
        if(@nr.to_i < 10) then
            value = @identifier + '-' + @@date.to_s + '-Board-0' + @nr.to_s
        else
            value = @identifier + '-' + @@date.to_s + '-Board-' + @nr.to_s
        end
        return value.gsub(' ','')
    end
    def setEvent(meta)
        @event = meta['ContestName']
        @@date = meta['ContestDate']
        @version = meta['Version']
        @generator = meta['Generator']
    end
    def setOptimumScore(contract,declarer,result)
        @contract = contract.gsub('K','D').gsub('P','S').gsub('P','S').gsub('T','C').gsub('N','NT')
        @declarer = declarer
        @result = result
    end
    def setNorth(spades, hearts, diamonds, clubs)
        @north = '{ "name" : "north" ,'
        @north += '"spades" : "' + transform(spades) + '" ,'
        @north += '"hearts" : "' + transform(hearts) + '" ,'
        @north += '"diamonds" : "' + transform(diamonds) + '" ,'
        @north += '"clubs" : "' + transform(clubs) + '"}'
    end
    def setEast(spades, hearts, diamonds, clubs)
        @east = '{ "name" : "east" ,'
        @east += '"spades" : "' + transform(spades) + '" ,'
        @east += '"hearts" : "' + transform(hearts) + '" ,'
        @east += '"diamonds" : "' + transform(diamonds) + '" ,'
        @east += '"clubs" : "' + transform(clubs) + '"}'
    end
    def setSouth(spades, hearts, diamonds, clubs)
        @south = '{ "name" : "south" ,'
        @south += '"spades" : "' + transform(spades) + '" ,'
        @south += '"hearts" : "' + transform(hearts) + '" ,'
        @south += '"diamonds" : "' + transform(diamonds) + '" ,'
        @south += '"clubs" : "' + transform(clubs) + '"}'
    end
    def setWest(spades, hearts, diamonds, clubs)
        @west = '{ "name" : "west" ,'
        @west += '"spades" : "' + transform(spades) + '" ,'
        @west += '"hearts" : "' + transform(hearts) + '" ,'
        @west += '"diamonds" : "' + transform(diamonds) + '" ,'
        @west += '"clubs" : "' + transform(clubs) + '"}'
    end
    def austeilung(n_s, n_h, n_d, n_c, e_s, e_h, e_d, e_c, s_s, s_h, s_d, s_c, w_s, w_h, w_d, w_c)
        @deal = "\"N:"
        @deal += transform(n_s) + '.' + transform(n_h) + '.' + transform(n_d) + '.' + transform(n_c) + ' '
        @deal += transform(e_s) + '.' + transform(e_h) + '.' + transform(e_d) + '.' + transform(e_c) + ' '
        @deal += transform(s_s) + '.' + transform(s_h) + '.' + transform(s_d) + '.' + transform(s_c) + ' '
        @deal += transform(w_s) + '.' + transform(w_h) + '.' + transform(w_d) + '.' + transform(w_c)
        @deal += "\""
    end
    def addContracts(declarer,contract,result,score)
        @contracttable << [declarer,contract,result,'',score.to_i]
    end
    def addTableScoreLine(line)
        liste=line.split()
        if (liste[2] != '--' and liste[3] != '--' and liste[-3] =~ /[-\d]+/)  then
            score = liste[-3].to_i
            liste[-2].gsub!(',','.')
            liste[-1].gsub!(',','.')
            p_ns = liste[-2].to_f
            p_ew = liste[-1].to_f
            if not @frequence.keys.include?(score) then
                @percentage_ns[score] = p_ns
                @percentage_ew[score] = p_ew
                @frequence[score] = 1
            else
                @frequence[score] += 1
            end
            if liste[-3] == '0' then
                @contracttable << ['-','Pass','-','',liste[-3]]                
            elsif liste[-3] =~ /A/ then
                @contracttable << ['-','-','-','',liste[-3]]                
            else
                if liste[-5] =~ /[NOSW]/ and liste[-4].length >= 1 then
                    declarer = liste[-5].gsub('O','E')
                    contract = liste[-6].gsub('K','D').gsub('P','S').gsub('P','S').gsub('T','C').gsub('N','NT')
                    @contracttable << [declarer,contract,liste[-4],'',liste[-3]]
                end
            end
        end
    end
    def addTableScoreLineWithLead(line)
        liste = line.split()
        if (liste[2] != '--' and liste[3] != '--' and liste[-3] =~ /[-\d]+/)  then
			pair_ns = liste[2]
			pair_ew = liste[3]
            score=liste[-3].to_i
            liste[-2].gsub!(',','.')
            liste[-1].gsub!(',','.')
            p_ns = liste[-2].to_f
            p_ew = liste[-1].to_f
            if not @frequence.keys.include?(score) then
                @percentage_ns[score] = p_ns
                @percentage_ew[score] = p_ew
                @frequence[score] = 1
            else
                @frequence[score] += 1
            end
            if liste[-3] == '0' then
                @contracttable << [pair_ns,pair_ew,'-','Pass','-','-',liste[-3]]                
            elsif liste[-3] =~ /A/ then
                @contracttable << [pair_ns,pair_ew,'-','-','-','-',liste[-3]]                
            else
                if liste[-6] =~ /[NOSW]/ and liste[-4].length >= 2 then
                    declarer = liste[-6].gsub('O','E')
                    contract = liste[-7].gsub('K','D').gsub('P','S').gsub('P','S').gsub('T','C').gsub('N','NT')
                    suit = liste[-4][0]
                    card = liste[-4][1]
                    suit=suit.gsub('K','D').gsub('P','S').gsub('P','S').gsub('T','C')
                    card=card.gsub('D','Q').gsub('B','J').gsub('1','T')
                    @contracttable << [pair_ns,pair_ew,declarer,contract,liste[-5],"#{suit}#{card}",liste[-3]]
                end
            end
        end
    end
    def addPairScoreLine(line)
        liste = line.split()
        if liste[-3] =~ /[-\d]+/ then
            score = liste[-3].to_i
            liste[-2].gsub!(',','.')
            liste[-1].gsub!(',','.')
            p_ns = liste[-2].to_f
            p_ew = liste[-1].to_f
            if not @frequence.keys.include?(score) then
                @percentage_ns[score] = p_ns
                @percentage_ew[score] = p_ew
                @frequence[score] = 1
            else
                @frequence[score] += 1
            end
        end
    end
    def to_hex(value)
        hex = ''
        case value.to_i
            when 10
                hex = 'A'
            when 11
                hex = 'B'
            when 12
                hex = 'C'
            when 13
                hex = 'D'
            else
                hex = value
        end
        return hex    
    end
    def setDDSolver(line)
        liste = line.split()
        case liste[0]
            when /^N/
                0.upto(4) do |n|
                    value = liste.pop
                    @ddsolver[5+n]  = to_hex(value)
                    @ddsolver[15+n] = to_hex(value)
                end
            when /^S/
                0.upto(4) do |n|
                    value = liste.pop
                    @ddsolver[15+n] = to_hex(value) if to_hex(value) != ':'
                end
            when /^O/
                0.upto(4) do |n|
                    value = liste.pop
                    @ddsolver[n]    = to_hex(value)
                    @ddsolver[10+n] = to_hex(value)
                end
            when /^W/
                0.upto(4) do |n|
                    value = liste.pop
                    @ddsolver[10+n] = to_hex(value) if to_hex(value) != ':'
                end            
        end
    end
    def addScoreTableLine(line)
        liste = line.split()
        if (liste.length > 3 and liste[-3] =~ /[-\d]+/) then
            liste[-2].gsub!(',','.')
            liste[-1].gsub!(',','.')
            p_ns = liste[-2].to_f
            p_ew = liste[-1].to_f
            @scoretable << "#{liste[-3].to_s.ljust(5)}\t#{liste[-4].to_s.rjust(3)}\t#{sprintf("%5.2f",p_ns.to_f)}\t#{sprintf("%5.2f",p_ew.to_f)}"
        end
    end
    def scoretable
        @frequence.sort.each do |score,freq|
            @scoretable << "#{score.to_s.ljust(5)}\t#{freq.to_s.rjust(3)}\t#{sprintf("%5.2f",@percentage_ns[score])}\t#{sprintf("%5.2f",@percentage_ew[score])}"
        end
        @scoretable
    end
    def contracttable
        table=[]
       ## @contracttable.sort{|x,y| y[6].to_i<=>x[6].to_i}.each do |entry|
        @contracttable.each do |entry|
            table << "#{entry[0].to_s}\t#{entry[1].to_s}\t#{entry[2].to_s}\t#{entry[3].to_s.ljust(5)}\t#{entry[4].to_s.ljust(3)}\t#{entry[5].to_s.ljust(2)}\t#{entry[6].to_s.rjust(6)}"
        end
        table
    end
    def getScores
        table = []
        @contracttable.each do |entry|
            table << '{ "pair_ns" : "' + entry[0].to_s + '", "pair_ew" : "' + entry[1].to_s + '", "declarer" : "' + entry[2].to_s + '", "contract" : "' + entry[3].to_s + '", "result" : "' + entry[4].to_s + '", "lead" : "' + entry[5].to_s + '", "score_ns" : "' + entry[6].to_s + '"},'
        end
        table
    end
    def setResult(totalscoretable)
        @totalscoretable = totalscoretable
    end
    def to_s
        message = '{'
        message += '"_id" : "' + getId() + '", ' + "\n"
        message += '"nr" : ' + @nr + ', ' + "\n"
        message += '"north" : ' + @north + ', ' + "\n"
        message += '"east" : ' + @east + ', ' + "\n"
        message += '"south" : ' + @south + ', ' + "\n"
        message += '"west" : ' + @west + ', ' + "\n"
        message += '"scores" : ['  + "\n"
        getScores().each do |score|
            message += score + "\n"
        end
        message += ']' + "\n"
        message += '},'
#        message = "\[Event \"#{@event}\"\]\n"
#        message += "\[Site \"#{@site}\"\]\n"
#        message += "\[Date \"#{@@date.gsub('-','.')}\"\]\n"
#        message += "\[Board \"#{@nr}\"\]\n"
#        message += "\[West \"?\"\]\n"
#        message += "\[North \"?\"\]\n"
#        message += "\[East \"?\"\]\n"
#        message += "\[South \"?\"\]\n"
#        message += "\[Dealer \"#{@dealer}\"\]\n"
#        message += "\[Vulnerable \"#{@vul}\"\]\n"
#        message += "\[Deal #{@deal}\]\n"
#        message += "\[Declarer \"#{@declarer}\"\]\n"
#        message += "\[Contract \"#{@contract}\"\]\n"
#        message += "\[Result \"#{@result}\"\]\n"
#        message += "\[Program \"#{@generator}\"\]\n"
#        message += "\[ProgramVersion \"#{@version}\"\]\n"
#        if @ddsolver.length>0 then
#            message += "\[DDSolver \"#{@ddsolver.join}\"\]\n"   
#        end
#        if @totalscoretable.length>0 then
#            message += "\[TotalScoreTable \"Rank;PairId;TotalMP;TotalPercentage;Names\"\]\n"
#            @totalscoretable.each do |line| 
#                message += "#{line}\n"
#            end
#        end
#        message += "\[ScoreTable \"Score_NS;Multiplicity;Percentage_NS;Percentage_EW\"\]\n"
#        scoretable.each do |line| 
#            message += "#{line}\n"
#        end
#        message += "\[ContractTable \"Pair_NS;Pair_EW;Declarer;Contract;Result;Lead;Score\"\]\n"
#        contracttable.each do |line| 
#            message += "#{line}\n"
#        end
#        message += "\n"
#        #ansi_msg = Iconv.iconv("LATIN1", "UTF-8", message).join
#        #ansi_msg = message.encode("Windows-1252")
#
#        message.encode("ISO-8859-1", "UTF-8")
        
    end

end

if $0 == __FILE__ 
    dat = ARGV[0]
    start = false
    total_scores = false
    metatags = Hash.new
    result = Array.new
    scores_table = false
    scores_pair = false
    counter = 0
    nr = 0
    dealer = ""
    vul = ""
    n_s, n_h, n_d, n_c = "", "", "", ""
    e_s, e_h, e_d, e_c = "", "", "", ""
    s_s, s_h, s_d, s_c = "", "", "", "" 
    w_s, w_h, w_d, w_c = "", "", "", ""
    entry = Array.new
    datei = File.open(dat)
    datei.each do  |line|  
        metatags[$1] = $2 if line =~ /^\s+<meta name="(.*)" content="(.*)"/
        total_scores = true if line =~ /^Platz/
        total_scores = false if line=~ /<a name="scoretables">/
        if total_scores and not (line =~ /^[NSOW]/) then
            if line =~ /([0-9,\/\s]+)\s{2}(.*)/ then
                rankline = $1.split()
                namestring = $2.split('   ').shift
                if namestring =~ /(.*) - (.*)/ then
                    name1 = $1
                    name2 = $2
                end
                if rankline.length >= 3 then
                    if rankline.length == 3 then
                        rank = '-'
                        id = rankline[0]
                        points = rankline[1].gsub!(',','.').to_f
                        percentage = rankline[2].gsub!(',','.').to_f
                    elsif rankline.length == 4 then
                        rank = rankline[0].split('/').shift
                        id = rankline[1]
                        points = rankline[2].gsub!(',','.').to_f
                        percentage = rankline[3].gsub!(',','.').to_f
                    end
                    result << "#{rank.rjust(3)}\t#{id.rjust(3)}\t#{sprintf("%7.3f",points)}\t#{sprintf("%7.3f",percentage)}\t\"#{name1};#{name2}\""
                end
            end
        end
        start = true if line =~ /<a name="scoretables">/
        start = false if start and line =~ /<a name="bottomofpage">/
        if start then
            # puts line
            line = line.gsub('! ','')
            if line =~ /-----------------/ then
                @p = Pbn.new
                if entry.empty? then
                    @p.setResult(result)
                    @p.setEvent(metatags)
                end
                entry << @p
                counter = 0
            else
                if entry.length > 0 then
                    counter += 1
                    case counter
                        when 1
                            (nr, n_s) = line.split()
                        when 2
                            (dealer, n_h) = line.split()
                        when 3
                            (vul, n_d) = line.split()
                        when 4
                            n_c = line.split().pop
                        when 5
                            (w_s, e_s) = line.split()
                        when 6
                            (w_h, e_h) = line.split()
                        when 7
                            (w_d, e_d) = line.split()
                        when 8
                            (w_c, e_c) = line.split()
                        when 9
                            s_s = line.split().pop
                        when 10
                            s_h = line.split().pop
                        when 11
                            s_d = line.split().pop
                        when 12
                            s_c = line.split().pop
                        when 13
                            @p.setBoardInfo(nr, dealer, vul)
                            @p.setNorth(n_s, n_h, n_d, n_c)
                            @p.setEast(e_s, e_h, e_d, e_c)
                            @p.setSouth(s_s, s_h, s_d, s_c)
                            @p.setWest(w_s, w_h, w_d, w_c)
                            @p.austeilung(n_s, n_h, n_d, n_c, e_s, e_h, e_d, e_c, s_s, s_h, s_d, s_c, w_s, w_h, w_d, w_c)
                        when 14
                            if not line =~/^\s+/ then
                                (cont, decl, score) = line.split()
                                @p.setOptimumScore(cont, decl, score)
                            end
                        when 16..19
                            @p.setDDSolver(line) if not line =~/^\s+/
                    end
                end
            end
        end
        scores_table = false if scores_table and (line =~ /^\s+$/ or line =~ /<\/a>/)
        if scores_table then
            #@p.addTableScoreLine(line)
			@p.addTableScoreLineWithLead(line)
        end
        scores_table = true if line =~ /^Tisch/
        
        scores_pair=false if scores_pair and (line =~ /^\s+$/ or line=~/<\/a>/)
        if scores_pair then
            @p.addPairScoreLine(line)
        end
        scores_pair=true if line =~ /^\s+Paar/        
    end
    
    
    result_xml = "#{dat}".gsub('.html','.pbn')
	f = File.new(result_xml, "w")
	f.write("% PBN 2.2\n")
	f.write("% EXPORT\n")
	f.write("%\n")
    entry.each do |pbn|
       f.write("#{pbn}")
    end
	f.close()
            
    result_json = "#{dat}".gsub('.html','.json')
	f = File.new(result_json, "w")
    f.write('{' + "\n")
    f.write("\t" + '"docs": [' + "\n")
    entry.each do |pbn|
        f.write("#{pbn}")
    end
    f.write("\t" + ']' + "\n")
    f.write('}')
	f.close()
end
