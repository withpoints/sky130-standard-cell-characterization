v {xschem version=3.4.7RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {NAND2.sym} 0 0 0 0 {name=x1}
C {devices/lab_pin.sym} 27.5 0 0 0 {name=l1 lab=VOUT}
C {devices/lab_pin.sym} -37.5 -20 0 0 {name=l2 lab=VIN}
C {devices/lab_pin.sym} -37.5 20 0 0 {name=l3 lab=VIN}
C {devices/lab_pin.sym} -2.5 35 0 0 {name=l4 lab=VDD}
C {devices/lab_pin.sym} -2.5 -35 0 0 {name=l5 lab=GND}
C {devices/vsource.sym} -200 -10 0 0 {name=Vin value="DC 0"}
C {devices/lab_pin.sym} -200 -40 0 0 {name=l6 lab=VIN}
C {devices/lab_pin.sym} -200 20 0 0 {name=l7 lab=GND}
C {devices/vsource.sym} -300 25 0 0 {name=Vdd value="DC 1.8"}
C {devices/lab_pin.sym} -300 -5 0 0 {name=l8 lab=VDD}
C {devices/lab_pin.sym} -300 55 0 0 {name=l9 lab=GND}
C {devices/gnd.sym} -400 0 0 0 {name=l10 lab=GND}
C {devices/code.sym} 0 -200 0 0 {name=MODELS
value="
.lib /usr/local/share/pdk/sky130B/libs.tech/ngspice/sky130.lib.spice tt
.option scale=1.0u
.dc Vin 0 1.8 0.005
"}
C {devices/simulator_commands.sym} 0 -300 0 0 {name=SIM
place=end
value="
.control
run
meas dc vm FIND v(VIN) WHEN v(VOUT)=0.9
wrdata nand2_vtc.csv v(VIN) v(VOUT)
print vm
.endc
"}
