# NAND2 layout build script for Magic (sky130A)
# Sizing: series NMOS W=2.0um (2x single-inverter NMOS, matches pull-down
# strength when stacked), parallel PMOS W=2.4um (same as single inverter,
# no upsizing needed since PMOS devices are in parallel).
#
# Device geometry used below (LOCAL coordinates relative to each device's
# own center, X independent of W, Y scales with channel half-height Ch=W/2):
#   nfet (any W): D-pad X=[-73,-15], S-pad X=[15,73] (diff), metal1 inset
#                 by 6 on each side. End caps at Y=[-Ch,-Ch+12] and
#                 [Ch-12,Ch]. Gate tab (used, "top"): polycont Y=[Ch+38,Ch+72].
#   pfet (any W): identical pattern, same X offsets, own Ch=W/2.
#   Measured half-extents (center-to-edge, i.e. device placement math):
#     nfet W=2.0 (Ch=200): half_extent=(73,288)
#     pfet W=2.4 (Ch=240): half_extent=(109,340)
#   gencell placement rule: box(bx,by) -> device CENTER = (2*bx+73, 2*by+Hy)
#
# Run: cd into this mag/ folder, then:  magic -dnull -noconsole build_nand2.tcl
# Verify with: check the printed "Total DRC errors found:" line (want 0),
# and inspect the extracted netlist device lines at the end.

load NAND2
box 0 0 0 0

# --- M1: NMOS series, TOP of stack (gate=A, D=Y, S=N1) ---
# center chosen so it lines up in the same X column as M3 (pmos, gate=A)
# box(0,300) -> center (73, 888)
box 0 300 0 300
magic::gencell sky130::sky130_fd_pr__nfet_01v8 nfet1 w 2.0 l 0.15 nf 1 m 1 guard 0

# --- M2: NMOS series, BOTTOM of stack (gate=B, D=N1, S=VGND) ---
# stacked directly below M1 with enough gap for the N1 strap + B gate tab
# box(0,-350) -> center (73, -412)
box 0 -350 0 -350
magic::gencell sky130::sky130_fd_pr__nfet_01v8 nfet2 w 2.0 l 0.15 nf 1 m 1 guard 0

# --- M3: PMOS parallel, gate=A, D=Y, S=VPWR --- (same X column as M1)
# box(-18,750) -> center (73, 1840)
box -18 750 -18 750
magic::gencell sky130::sky130_fd_pr__pfet_01v8 pfet1 w 2.4 l 0.15 nf 1 m 1 guard 0

# --- M4: PMOS parallel, gate=B, D=Y, S=VPWR --- (separate X column, far
# enough right to give the B-gate and Y jogs plenty of clearance)
# box(282,750) -> center (673, 1840)  [X offset = 600 from M3]
box 282 750 282 750
magic::gencell sky130::sky130_fd_pr__pfet_01v8 pfet2 w 2.4 l 0.15 nf 1 m 1 guard 0

# ============================================================
# Absolute pin geometry (derived from centers above + the local
# offsets documented at the top of this file):
#   M1 (nfet, Ch=200) center (73,888):
#     D(Y)-pad top-cap   X=[6,52]   Y=[1064,1088]   (Ch-12..Ch => 888+188..888+200)
#     S(N1)-pad bot-cap  X=[94,140] Y=[688,712]     (-Ch..-Ch+12 => 888-200..888-188)
#     A gate tab (top)   X=[56,90]  Y=[1126,1160]   (Ch+38..Ch+72 => 888+238..888+272)
#   M2 (nfet, Ch=200) center (73,-412):
#     D(N1)-pad top-cap  X=[6,52]   Y=[-236,-212]
#     S(VGND)-pad botcap X=[94,140] Y=[-612,-588]
#     B gate tab (top)   X=[56,90]  Y=[-174,-140]
#   M3 (pfet, Ch=240) center (73,1840):
#     D(Y)-pad bot-cap   X=[6,52]   Y=[1600,1624]   (-Ch..-Ch+24, using pfet
#                                                     cap width; see INV notes)
#     S(VPWR)-pad topcap X=[94,140] Y=[2056,2080]
#     A gate tab (bottom)X=[56,90]  Y=[1553,1587]   (-Ch-72..-Ch-38)
#   M4 (pfet, Ch=240) center (673,1840):
#     D(Y)-pad bot-cap   X=[606,652] Y=[1600,1624]
#     S(VPWR)-pad topcap X=[694,740] Y=[2056,2080]
#     B gate tab (bottom)X=[656,690] Y=[1553,1587]
# ============================================================

# --- VGND rail (bottom) ---
box -300 -700 900 -640
paint metal1

# --- VPWR rail (top) ---
box -300 2140 900 2200
paint metal1

# --- P-substrate tap (VGND), placed clear of everything at far left ---
box -250 -700 -170 -660
paint pwell
box -250 -700 -170 -660
paint psubdiff
box -230 -690 -190 -670
paint psubdiffcont
box -246 -706 -174 -654
paint locali
box -246 -706 -174 -654
paint viali
box -258 -718 -162 -642
paint metal1

# --- N-well tap (VPWR): bridge nwell from x=-36 (inside M3's own nwell,
# which spans center73+-109 = [-36,182]) out to the tap, generous overlap ---
box -350 2064 -36 2216
paint nwell
box -250 2140 -170 2180
paint nsubdiff
box -230 2150 -190 2170
paint nsubdiffcont
box -246 2134 -174 2186
paint locali
box -246 2134 -174 2186
paint viali
box -258 2122 -162 2198
paint metal1

# --- VGND strap: M2 S-pad (bottom cap, X=[94,140] Y=[-612,-588]) down to rail ---
box 130 -640 170 -560
paint metal1

# --- VPWR strap: M3 S-pad (top cap, X=[94,140] Y=[2056,2080]) up to rail,
# and M4 S-pad (X=[694,740] Y=[2056,2080]) up to rail ---
box 130 2000 170 2140
paint metal1
box 730 2000 770 2140
paint metal1

# --- N1 internal strap: M1 S-pad (bottom cap X=[94,140] Y=[688,712]) to
# M2 D-pad (top cap X=[6,52] Y=[-236,-212]). Route at X=150..190 (clear of
# M1's A-gate tab X=[56,90] and clear of M2's B-gate tab X=[56,90]) --
box 6 -236 190 -212
paint metal1
box 150 -212 190 712
paint metal1
box 94 688 190 712
paint metal1

# --- A gate strap: M1 top tab (X=[56,90] Y=[1126,1160]) to M3 bottom tab
# (X=[56,90] Y=[1553,1587]) -- straight vertical run, same X column ---
box 56 1160 90 1553
paint locali

# --- B gate strap: M2 top tab (X=[56,90] Y=[-174,-140]) over to M4 bottom
# tab (X=[656,690] Y=[1553,1587]). Route up at X=[190,230] (clear of
# everything else in that column), jog across at a height clear of all
# other features (y=900, between M1 top ~1088 and M3 bottom ~1600),
# then up to M4's tab X range. ---
box 190 -160 230 900
paint locali
box 190 890 700 920
paint locali
box 656 900 700 1587
paint locali

# --- Y (output) strap: M1 D-pad (top cap X=[6,52] Y=[1064,1088]) to M3
# D-pad (bottom cap X=[6,52] Y=[1600,1624]) -- straight vertical, clear of
# the A-gate strap at X=[56,90] since Y uses X=[6,52] only. Then jog over
# to M4's D-pad (X=[606,652] Y=[1600,1624]) via a channel well clear of
# the B-gate strap (X 190-700 around y=890-920) -- route the Y jog at
# y=1300 (clear of B-gate's y=890-920 crossing zone). ---
box 6 1088 52 1624
paint metal1
box 6 1290 652 1320
paint metal1
box 606 1290 652 1624
paint metal1

# --- Pin labels ---
box -258 -700 -162 -660
label VGND c metal1
port 4 nsew ground bidirectional
box -258 2140 -162 2180
label VPWR c metal1
port 5 nsew power bidirectional
box 606 1290 652 1320
label Y c metal1
port 3 nsew output
box 56 1300 90 1350
label A c locali
port 1 nsew input
box 190 895 230 915
label B c locali
port 2 nsew input

select top cell
box
drc catchup
drc count total
box -400 -800 1000 2300
drc why

writeall force

flatten NAND2_FLAT
load NAND2_FLAT
select top cell
box
drc catchup
drc count total
save NAND2_FLAT

extract path /home/rohit/projects/P1/nand/phase2/spice
extract all
quit -noprompt
