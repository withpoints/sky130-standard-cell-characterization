#!/usr/bin/env python3
"""Quick validation of the widened measurement windows on two points:
one that already worked (slew=100ps, cload=10fF) and the worst case that
was broken before (slew=500ps, cload=50fF)."""
import sys
sys.path.insert(0, ".")
from characterize import run_point

for slew, cload, label in [(100e-12, 10e-15, "previously-good point"),
                            (500e-12, 50e-15, "worst-case (was broken)")]:
    print(f"\n=== {label}: slew={slew*1e12:.0f}ps cload={cload*1e15:.0f}fF (TT) ===")
    values = run_point(slew, cload, "tt")
    for k, v in values.items():
        print(f"  {k} = {v:.6e}")
