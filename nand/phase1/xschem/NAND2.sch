v {xschem version=3.4.7RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/opin.sym} 750 -310 0 0 {name=p1 lab=Y}
C {devices/ipin.sym} 200 -100 0 0 {name=p2 lab=A}
C {devices/ipin.sym} 150 -220 0 0 {name=p3 lab=B}
C {devices/ipin.sym} 530 -340 0 0 {name=p4 lab=VPWR}
C {devices/ipin.sym} 530 -100 0 0 {name=p5 lab=VGND}
C {sky130_fd_pr/nfet_01v8.sym} 400 -100 0 0 {name=M1
L=0.15
W=2.0
nf=1 mult=1
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 400 -220 0 0 {name=M2
L=0.15
W=2.0
nf=1 mult=1
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 400 -340 0 0 {name=M3
L=0.15
W=2.4
nf=1 mult=1
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 600 -340 0 0 {name=M4
L=0.15
W=2.4
nf=1 mult=1
model=pfet_01v8
spiceprefix=X
}
C {devices/lab_pin.sym} 420 -130 0 0 {name=l1 lab=Y}
C {devices/lab_pin.sym} 380 -100 0 0 {name=l2 lab=A}
C {devices/lab_pin.sym} 420 -70 0 0 {name=l3 lab=N1}
C {devices/lab_pin.sym} 420 -100 0 0 {name=l4 lab=VGND}
C {devices/lab_pin.sym} 420 -250 0 0 {name=l5 lab=N1}
C {devices/lab_pin.sym} 380 -220 0 0 {name=l6 lab=B}
C {devices/lab_pin.sym} 420 -190 0 0 {name=l7 lab=VGND}
C {devices/lab_pin.sym} 420 -220 0 0 {name=l8 lab=VGND}
C {devices/lab_pin.sym} 420 -310 0 0 {name=l9 lab=Y}
C {devices/lab_pin.sym} 380 -340 0 0 {name=l10 lab=A}
C {devices/lab_pin.sym} 420 -370 0 0 {name=l11 lab=VPWR}
C {devices/lab_pin.sym} 420 -340 0 0 {name=l12 lab=VPWR}
C {devices/lab_pin.sym} 620 -310 0 0 {name=l13 lab=Y}
C {devices/lab_pin.sym} 580 -340 0 0 {name=l14 lab=B}
C {devices/lab_pin.sym} 620 -370 0 0 {name=l15 lab=VPWR}
C {devices/lab_pin.sym} 620 -340 0 0 {name=l16 lab=VPWR}
