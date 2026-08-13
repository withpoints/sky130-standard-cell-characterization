* INV: input slew x output load sweep characterization
.param tslew=100p
.param cl=10f

.subckt INV Y A VPWR VGND
XM1 Y A VGND VGND sky130_fd_pr__nfet_01v8 L=0.15 W=1.0 nf=1 mult=1
XM2 Y A VPWR VPWR sky130_fd_pr__pfet_01v8 L=0.15 W=2.4 nf=1 mult=1
.ends

Vdd VDD 0 DC 1.8
Vin VIN 0 PULSE(0 1.8 1n {tslew} {tslew} 5n 10n)
Cload VOUT 0 {cl}
x1 VOUT VIN VDD 0 INV

.lib /usr/local/share/pdk/sky130B/libs.tech/ngspice/sky130.lib.spice tt
.option scale=1.0u

.control
echo "slew_s,cload_F,tpHL_s,tpLH_s" > ../sim/inv_sweep.csv
foreach sl 50p 100p 200p 500p
  foreach clv 5f 10f 25f 50f 100f
    alterparam tslew=$sl
    alterparam cl=$clv
    reset
    tran 5p 20n
    meas tran tphl trig v(VIN) val=0.9 rise=1 targ v(VOUT) val=0.9 fall=1
    meas tran tplh trig v(VIN) val=0.9 fall=1 targ v(VOUT) val=0.9 rise=1
    echo "$sl,$clv,$&tphl,$&tplh" >> ../sim/inv_sweep.csv
  end
end
.endc
.end
