v {xschem version=3.4.7RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 420 -260 420 -230 {lab=Y}
N 420 -260 460 -260 {lab=Y}
N 380 -260 380 -200 {lab=A}
N 340 -260 380 -260 {lab=A}
N 420 -400 420 -360 {lab=VPWR}
N 420 -160 420 -140 {lab=VGND}
N 420 -200 500 -200 { lab=VGND}
N 500 -200 500 -160 { lab=VGND}
N 420 -160 500 -160 { lab=VGND}
N 420 -360 500 -360 { lab=VPWR}
N 500 -360 500 -320 { lab=VPWR}
N 420 -320 500 -320 { lab=VPWR}
N 380 -320 380 -260 { lab=A}
N 420 -290 420 -260 {lab=Y}
N 420 -170 420 -160 { lab=VGND}
N 420 -360 420 -350 { lab=VPWR}
C {devices/opin.sym} 460 -260 0 0 {name=p1 lab=Y}
C {devices/ipin.sym} 340 -260 0 0 {name=p2 lab=A}
C {devices/ipin.sym} 420 -400 0 0 {name=p3 lab=VPWR}
C {devices/ipin.sym} 420 -140 0 0 {name=p4 lab=VGND}
C {sky130_fd_pr/nfet_01v8.sym} 400 -200 0 0 {name=M1
L=0.15
W=0.42
nf=1 mult=1
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 400 -320 0 0 {name=M2
L=0.15
W=1.26
nf=1 mult=1
model=pfet_01v8
spiceprefix=X
}
