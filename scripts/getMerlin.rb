# ******************************************************************************** 
# getMerlin.rb
# ******************************************************************************** 
require 'open-uri'
def board(nr)
  #homepage = "http://www.bridge-verband.de/images/uploads/ftp3390/Bundesligen/"
  homepage = "http://www.bridge-suedbayern.de/2016/IBPM/EndErg/"
  #homepage = "http://www.bridgeclubkirchzarten.de/ergebnisse2016/
  #bezeichner = "16_11_11_bez_bdz_k2_bd"
  bezeichner = "16_11_11_bez_bdz_k0_d2_bd"
  #bezeichner = "16_10_22_bez_bdz_k0_d2_bd"
  url = "#{homepage}#{bezeichner}#{nr}.html"
  page = open(url)
  page.read
end

if $0 == __FILE__ 
    for nr in 1..26 do 
        file = open("board_" + nr.to_s + ".html", 'w')
        file.write(board(nr))
        file.close
    end
end
