* Single-point characterization test: INV cell, TT corner, nominal V/T
.param slew=100p
.param cload=10f
.param vdd_val=1.8

.include inverter_pex_subckt.spice

Vdd VDD 0 DC {vdd_val}
Vin VIN 0 PULSE(0 {vdd_val} 2n {slew} {slew} 5n 10n)
Cload OUT 0 {cload}
Xdut OUT VIN VDD 0 inverter_pex

.lib /usr/local/share/pdk/sky130B/libs.tech/ngspice/sky130.lib.spice tt
.option scale=1.0u

.control
tran 1p 15n
* positive pwr = power actually drawn FROM the supply (ngspice reports
* source current with the opposite sign convention, so negate it)
let pwr = -i(Vdd)*v(VDD)

* propagation delays (50% to 50%) -- literal values since vdd_val=1.8
meas tran tpHL trig v(VIN) val=0.9 rise=1 targ v(OUT) val=0.9 fall=1
meas tran tpLH trig v(VIN) val=0.9 fall=1 targ v(OUT) val=0.9 rise=1

* output transition times (10%-90%)
meas tran tfall trig v(OUT) val=1.62 fall=1 targ v(OUT) val=0.18 fall=1
meas tran trise trig v(OUT) val=0.18 rise=1 targ v(OUT) val=1.62 rise=1

* dynamic energy per transition: integrate supply power over a tight window
* bracketing just the switching edge (input edges are at 2n and 7n)
meas tran e_hl INTEG pwr from=1.9n to=2.5n
meas tran e_lh INTEG pwr from=6.9n to=7.5n

* leakage: quiescent VDD current with input held low/high (positive = drawn from supply)
meas tran i_leak_lo avg pwr from=0.2n to=1.8n
meas tran i_leak_hi avg pwr from=3n to=4.8n

wrdata inverter_char_single.csv v(VIN) v(OUT)
.endc
.end
