* Parameterized characterization deck for INV cell (template, filled by Python)
.param slew=__SLEW__
.param cload=__CLOAD__
.param vdd_val=__VDD__

.include inverter_pex_subckt.spice

Vdd VDD 0 DC {vdd_val}
Vin VIN 0 PULSE(0 {vdd_val} 2n {slew} {slew} 5n 10n)
Cload OUT 0 {cload}
Xdut OUT VIN VDD 0 inverter_pex

.lib /usr/local/share/pdk/sky130B/libs.tech/ngspice/sky130.lib.spice __CORNER__
.option scale=1.0u
.option temp=__TEMP__

.control
tran 1p 18n
let pwr = -i(Vdd)*v(VDD)

meas tran tpHL trig v(VIN) val=__VDD_HALF__ rise=1 targ v(OUT) val=__VDD_HALF__ fall=1
meas tran tpLH trig v(VIN) val=__VDD_HALF__ fall=1 targ v(OUT) val=__VDD_HALF__ rise=1
meas tran tfall trig v(OUT) val=__VDD_90__ fall=1 targ v(OUT) val=__VDD_10__ fall=1
meas tran trise trig v(OUT) val=__VDD_10__ rise=1 targ v(OUT) val=__VDD_90__ rise=1

* windows widened to comfortably cover the worst case observed across the
* full slew x load matrix (max settling ~660ps at slew=500ps/cload=50fF),
* instead of the old fixed 0.6ns windows that clipped slow transitions.
meas tran e_hl INTEG pwr from=1.8n to=4n
meas tran e_lh INTEG pwr from=6.8n to=9n

* leakage: quiet windows -- before the first edge starts (always safe,
* independent of slew/load) and after HL settling but before the next edge
meas tran p_leak_lo avg pwr from=1.0n to=1.9n
meas tran p_leak_hi avg pwr from=5n to=6.7n
.endc
.end
