load inverter
select top cell
box
puts "CELL_BBOX [box values]"

box -26 -38 -24 -36
select chunk locali
puts "PIN_G_BBOX [select bbox]"
select clear

box 109 -48 111 -46
select chunk locali
puts "PIN_OUT_BBOX [select bbox]"
select clear

box -72 65 -70 67
select chunk metal1
puts "PIN_VDD_BBOX [select bbox]"
select clear

box -68 -91 -66 -89
select chunk metal1
puts "PIN_VSS_BBOX [select bbox]"
select clear
quit -noprompt
