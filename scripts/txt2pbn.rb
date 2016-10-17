# ******************************************************************************** 
# txt2pbn.rb
#                                                                                  
# ******************************************************************************** -->
unless ARGV.length == 1 
  puts "Usage: txt2pbn.rb datei"
  exit
end
class Pbn
    attr_writer  :vulnerable
    def initialize(board)
        @board = board
        @frequence = {}
        @percentage_ns = {}
        @percentage_ew = {}
        @scoretable = []
    end
    def transform (text)
        text.to_s.gsub("---",'').gsub("10",'T').gsub("D",'Q').gsub("B",'J')
    end
    def setBoardInfo(nr,dealer,vul)
        @nr = nr
        if dealer=="Nord"
            @dealer="N"
        elsif dealer=="Ost"
            @dealer="E"
        elsif dealer=="West"
            @dealer="W"
        else
            @dealer="S"
        end
        if vul=="Keine"
            @vul="None"
        elsif vul=="N-S"
            @vul="NS"
        elsif vul=="O-W"
            @vul="EW"
        else
            @vul="All"
        end
    end
    def setEvent(event,site,date)
        @event = event
        @site = site
        @date = date
    end
    def austeilung(north,east,south,west)
        @deal = "\"N:"
        @deal += transform(north)+' '
        @deal += transform(east)+' '
        @deal += transform(south)+' '
        @deal += transform(west)
        @deal += "\""
    end
    def addTableScoreLine(line)
        liste=line.split()
        if (liste[2]!='--' and liste[3]!='--') then
            if !( liste[-3].include?('/')or liste[-3].include?(';') ) then
                score=liste[-3].to_i
                liste[-2].gsub!(',','.')
                liste[-1].gsub!(',','.')
                p_ns=liste[-2].to_f
                p_ew=liste[-1].to_f
                if not @frequence.keys.include?(score) then
                    @percentage_ns[score]=p_ns
                    @percentage_ew[score]=p_ew
                    @frequence[score]=1
                else
                    @frequence[score]+=1
                end
            end
        end
    end
    def addPairScoreLine(line)
        liste=line.split()
        if !( liste[-5].include?('/') or liste[-5].include?(';') ) then
            score=liste[-5].to_i
            liste[-2].gsub!(',','.')
            liste[-1].gsub!(',','.')
            p_ns=liste[-2].to_f
            p_ew=liste[-1].to_f
            if not @frequence.keys.include?(score) then
                @percentage_ns[score]=p_ns
                @percentage_ew[score]=p_ew
                @frequence[score]=1
            else
                @frequence[score]+=1
            end
        end
    end
    def scoretable
        @frequence.sort.each do |score,freq|
            @scoretable<<"#{score.to_s.ljust(5)}\t#{freq.to_s.rjust(3)}\t#{sprintf("%5.2f",@percentage_ns[score])}\t#{sprintf("%5.2f",@percentage_ew[score])}"
        end
        @scoretable
    end
    def to_s
        message = "\[Event \"#{@event}\"\]\n"
        message += "\[Site \"#{@site}\"\]\n"
        message += "\[Date \"#{@date}\"\]\n"
        message += "\[Board \"#{@nr}\"\]\n"
        message += "\[West \"?\"\]\n"
        message += "\[North \"?\"\]\n"
        message += "\[East \"?\"\]\n"
        message += "\[South \"?\"\]\n"
        message += "\[Dealer \"#{@dealer}\"\]\n"
        message += "\[Vulnerable \"#{@vul}\"\]\n"
        message += "\[Deal #{@deal}\]\n"
        message += "\[Declarer \"?\"\]\n"
        message += "\[Contract \"?\"\]\n"
        message += "\[Result \"?\"\]\n"
        message += "\[ScoreTable \"Score_NS;Multiplicity;Percentage_NS;Percentage_EW\"\]\n"
        scoretable.each do |line| 
            message += "#{line}\n"
        end
        message += "\n"
        return message
    end

end

if $0 == __FILE__ 
    dat = ARGV[0]
    start=false
    # scores_table=false
    # scores_pair=false
    board = 0
    l = 0
    entry = Array.new
    datei = File.open(dat)
    datei.each do  |line|   
        if line =~ /^(\d{4})-(\d{2})-(\d{2})\s{2}(.*)/
            @date = "#{$1}.#{$2}.#{$3}"
            @event = "#{$4}"
            @site = ""
        end
        # start=true if line =~/<a name=\"scoretables\">/
        start=true if line =~/--------/
        start=false if start and line=~/^\s*$/
        if start then
            if line =~ /-----------------/ then
                @p = Pbn.new(board)
                if board > 0 then
                  entry << @p
                end
                board += 1
                l = 0
            else
                if entry.length > 0 then
                    l+=1
                    if l==1 then
                        (@nr,n_s) = line.split()
                        @north=n_s+'.'
                    elsif l==2 then
                        (@dealer,n_h) = line.split()
                        @north+=n_h+'.'
                    elsif l==3 then
                        (@vul,n_d) = line.split()
                        @north+=n_d+'.'
                    elsif l==4 then
                        n_c = line.split().pop
                        @north+=n_c
                    elsif l==5 then
                        (w_s,e_s) = line.split()
                        @west=w_s+'.'
                        @east=e_s+'.'
                    elsif l==6 then
                        (w_h,e_h) = line.split()
                        @west+=w_h+'.'
                        @east+=e_h+'.'
                    elsif l==7 then
                        (w_d,e_d) = line.split()
                        @west+=w_d+'.'
                        @east+=e_d+'.'
                    elsif l==8 then
                        (w_c,e_c) = line.split()
                        @west+=w_c
                        @east+=e_c
                    elsif l==9 then
                        s_s = line.split().pop
                        @south=s_s+'.'
                    elsif l==10 then
                        s_h = line.split().pop
                        @south+=s_h+'.'
                    elsif l==11 then
                        s_d = line.split().pop
                        @south+=s_d+'.'
                    elsif l==12 then
                        s_c = line.split().pop
                        @south+=s_c
                        @p.setEvent(@event, @site, @date)
                        @p.setBoardInfo(@nr,@dealer,@vul)
                        @p.austeilung(@north,@east,@south,@west)
                    end
                end
            end
        end
        # scores_table=false if scores_table and (line =~ /^\s+/ or line=~/<\/a>/)
        # if scores_table then
         #    @p.addTableScoreLine(line)
        # end
        # scores_table=true if line =~ /^Tisch/
        
        # scores_pair=false if scores_pair and (line =~ /^\s+$/ or line=~/<\/a>/)
        # if scores_pair then
        #     @p.addPairScoreLine(line)
        # end
        # scores_pair=true if line =~ /^\s+Paar/
        
    end
    entry.each do |pbn|
        puts pbn
    end
end
