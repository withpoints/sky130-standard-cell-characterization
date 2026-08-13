v {xschem version=3.4.7RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {INV.sym} 0 0 0 0 {name=x1}
C {devices/lab_pin.sym} 32.5 0 0 0 {name=l1 lab=VOUT}
C {devices/lab_pin.sym} -32.5 -10 0 0 {name=l2 lab=VIN}
C {devices/lab_pin.sym} -2.5 25 0 0 {name=l3 lab=VDD}
C {devices/lab_pin.sym} -2.5 -25 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} -200 -10 0 0 {name=Vin value="PULSE(0 1.8 1n 100p 100p 5n 10n)"}
C {devices/lab_pin.sym} -200 -40 0 0 {name=l5 lab=VIN}
C {devices/lab_pin.sym} -200 20 0 0 {name=l6 lab=GND}
C {devices/vsource.sym} -300 25 0 0 {name=Vdd value="DC 1.8"}
C {devices/lab_pin.sym} -300 -5 0 0 {name=l7 lab=VDD}
C {devices/lab_pin.sym} -300 55 0 0 {name=l8 lab=GND}
C {devices/capa.sym} 150 -10 0 0 {name=Cload value=10f}
C {devices/lab_pin.sym} 150 -40 0 0 {name=l9 lab=VOUT}
C {devices/lab_pin.sym} 150 20 0 0 {name=l10 lab=GND}
C {devices/gnd.sym} -400 0 0 0 {name=l11 lab=GND}
C {devices/code.sym} 0 -200 0 0 {name=MODELS
value="
.lib /usr/local/share/pdk/sky130B/libs.tech/ngspice/sky130.lib.spice tt
.option scale=1.0u
.tran 10p 20n
"}
C {devices/simulator_commands.sym} 0 -300 0 0 {name=SIM
place=end
value="
.control
run
meas tran tpHL trig v(VIN) val=0.9 rise=1 targ v(VOUT) val=0.9 fall=1
meas tran tpLH trig v(VIN) val=0.9 fall=1 targ v(VOUT) val=0.9 rise=1
meas tran tf_out trig v(VOUT) val=1.62 fall=1 targ v(VOUT) val=0.18 fall=1
meas tran tr_out trig v(VOUT) val=0.18 rise=1 targ v(VOUT) val=1.62 rise=1
wrdata inv_tran.csv v(VIN) v(VOUT)
.endc
"}
