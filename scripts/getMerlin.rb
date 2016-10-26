# ******************************************************************************** 
# getMerlin.rb
# ******************************************************************************** 
require 'open-uri'

def board(nr)
  homepage = "http://www.bridgeclubkirchzarten.de/ergebnisse2016/"
  bezeichner = "16_10_22_bez_bdz_k1_bd"
  url = "#{homepage}#{bezeichner}#{nr}.html"
  page = open(url)
  page.read
end

if $0 == __FILE__ 
    for nr in 1..30 do 
        file = open("board_" + nr.to_s + ".html", 'w')
        file.write(board(nr))
        file.close
    end
end
