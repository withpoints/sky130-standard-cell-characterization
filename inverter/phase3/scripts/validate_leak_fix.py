#!/usr/bin/env python3
import sys
sys.path.insert(0, ".")
from characterize import run_point

for slew, cload, corner in [(500e-12, 50e-15, "ss"), (20e-12, 1e-15, "ss")]:
    print(f"\n=== slew={slew*1e12:.0f}ps cload={cload*1e15:.0f}fF ({corner}) ===")
    values = run_point(slew, cload, corner)
    print(f"  p_leak_lo = {values.get('p_leak_lo', float('nan'))*1e12:.4f} pW")
    print(f"  p_leak_hi = {values.get('p_leak_hi', float('nan'))*1e12:.4f} pW")
