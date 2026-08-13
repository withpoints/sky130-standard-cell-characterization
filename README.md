# Sky130 Standard Cell Characterization

A from-scratch standard-cell design and characterization flow built on the open-source **SkyWater Sky130** PDK — no proprietary tools (Cadence/Synopsys). Every stage, from schematic to a foundry-style timing library, is done with the open-source EDA stack: **Xschem, ngspice, Magic, Python**.

Cells implemented: **INV** (fully characterized), **NAND2** (layout + LVS done, characterization in progress).

## Flow

```
Phase 1 — Schematic & functional verification
  Xschem schematic capture + symbol
  ngspice transient / VTC testbenches, parametric sweeps

Phase 2 — Physical layout
  Transistor-level layout in Magic (Sky130 devices)
  DRC-clean, LVS-verified against the schematic
  Parasitic extraction (.ext -> extracted SPICE netlist)

Phase 3 — Timing characterization
  SPICE sweeps over input slew x output load, 3 corners (TT / SS / FF)
  Propagation delay (tpHL / tpLH) extraction -> NLDM lookup tables
  Liberty (.lib) timing views generated per corner
  LEF abstract view generated for place & route
```

## Repo layout

```
<cell>/
  phase1/   xschem/   schematic + symbol + testbenches
            scripts/  SPICE sweep decks
  phase2/   mag/      Magic layout + LVS/extraction scripts
            spice/    extracted netlists, LVS logs
  phase3/   scripts/  characterize.py, gen_liberty.py
            results/  NLDM delay tables (per corner, per edge)
            lib/      generated .lib (TT/SS/FF) + .lef
```

## Sample results (INV, slew=20ps sweep, TT corner)

| Cload (fF) | tpHL (ps) | tpLH (ps) |
|---|---|---|
| 1  | 23.0  | 19.0  |
| 5  | 43.2  | 35.5  |
| 10 | 67.7  | 55.8  |
| 25 | 140.5 | 116.2 |

Full sweep across TT/SS/FF corners and all load/slew points is in `inverter/phase3/results/`.

## Toolchain

- [Xschem](https://xschem.sourceforge.io/) — schematic capture
- [ngspice](https://ngspice.sourceforge.io/) — circuit simulation
- [Magic VLSI](http://opencircuitdesign.com/magic/) — layout, DRC, LVS, extraction
- [Sky130 PDK](https://github.com/google/skywater-pdk) — open-source 130nm process
- Python (custom NLDM extraction + Liberty generation scripts)
