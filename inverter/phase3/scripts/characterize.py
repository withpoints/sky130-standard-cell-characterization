#!/usr/bin/env python3
"""
Standard-cell characterization sweep for the sky130 INV layout (inverter.mag).
Sweeps input slew x output load across TT/SS/FF process corners at nominal
V/T, running ngspice for each point and parsing delay/transition/energy/
leakage measurements into NLDM-style CSV tables.
"""
import subprocess
import re
import csv
import os
from concurrent.futures import ThreadPoolExecutor, as_completed

NUM_WORKERS = 4  # matches available CPU cores

SIM_DIR = os.path.expanduser("~/projects/vlsi_phase3/sim")
RESULTS_DIR = os.path.expanduser("~/projects/vlsi_phase3/results")
TEMPLATE_PATH = os.path.join(SIM_DIR, "char_template.sp")
SCRATCH_DIR = os.path.join(SIM_DIR, "scratch")

SLEWS_S = [20e-12, 50e-12, 100e-12, 200e-12, 500e-12]   # seconds
LOADS_F = [1e-15, 5e-15, 10e-15, 25e-15, 50e-15]        # farads
CORNERS = ["tt", "ss", "ff"]
VDD = 1.8
TEMP_C = 27

MEAS_NAMES = ["tphl", "tplh", "tfall", "trise", "e_hl", "e_lh", "p_leak_lo", "p_leak_hi"]
MEAS_RE = re.compile(r"^(\w+)\s*=\s*([-\d.eE+]+)")


def fmt_eng(x):
    """Format a float in spice-friendly form, e.g. 1e-12 -> '1p'."""
    return f"{x:.6e}"


def build_deck(slew, cload, corner):
    with open(TEMPLATE_PATH) as f:
        text = f.read()
    text = text.replace("__SLEW__", fmt_eng(slew))
    text = text.replace("__CLOAD__", fmt_eng(cload))
    text = text.replace("__VDD__", str(VDD))
    text = text.replace("__CORNER__", corner)
    text = text.replace("__TEMP__", str(TEMP_C))
    text = text.replace("__VDD_HALF__", str(VDD / 2))
    text = text.replace("__VDD_10__", str(VDD * 0.1))
    text = text.replace("__VDD_90__", str(VDD * 0.9))
    return text


def run_point(slew, cload, corner):
    os.makedirs(SCRATCH_DIR, exist_ok=True)
    deck = build_deck(slew, cload, corner)
    deck_path = os.path.join(SCRATCH_DIR, f"pt_{corner}_{slew:.0e}_{cload:.0e}.sp")
    with open(deck_path, "w") as f:
        f.write(deck)

    try:
        result = subprocess.run(
            ["ngspice", "-b", deck_path],
            cwd=SIM_DIR,
            capture_output=True,
            text=True,
            timeout=150,
        )
        out = result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        print(f"  WARNING: ngspice timed out (150s) on {deck_path}, skipping point")
        return {}

    values = {}
    for line in out.splitlines():
        m = MEAS_RE.match(line.strip())
        if m and m.group(1) in MEAS_NAMES:
            values[m.group(1)] = float(m.group(2))

    missing = [m for m in MEAS_NAMES if m not in values]
    if missing:
        print(f"  WARNING: corner={corner} slew={slew:.3g} cload={cload:.3g} missing {missing}")
        print("  --- ngspice output tail ---")
        print("\n".join(out.splitlines()[-15:]))

    return values


def _values_to_row(corner, slew, cload, values):
    return {
        "corner": corner,
        "slew_ps": slew * 1e12,
        "cload_fF": cload * 1e15,
        "tpHL_ps": values.get("tphl", float("nan")) * 1e12,
        "tpLH_ps": values.get("tplh", float("nan")) * 1e12,
        "tfall_ps": values.get("tfall", float("nan")) * 1e12,
        "trise_ps": values.get("trise", float("nan")) * 1e12,
        "e_hl_fJ": values.get("e_hl", float("nan")) * 1e15,
        "e_lh_fJ": values.get("e_lh", float("nan")) * 1e15,
        "p_leak_lo_pW": values.get("p_leak_lo", float("nan")) * 1e12,
        "p_leak_hi_pW": values.get("p_leak_hi", float("nan")) * 1e12,
    }


def main():
    os.makedirs(RESULTS_DIR, exist_ok=True)
    points = [(corner, slew, cload)
              for corner in CORNERS for slew in SLEWS_S for cload in LOADS_F]
    total = len(points)

    out_csv = os.path.join(RESULTS_DIR, "inv_characterization.csv")
    fieldnames = ["corner", "slew_ps", "cload_fF", "tpHL_ps", "tpLH_ps",
                  "tfall_ps", "trise_ps", "e_hl_fJ", "e_lh_fJ",
                  "p_leak_lo_pW", "p_leak_hi_pW"]
    csv_file = open(out_csv, "w", newline="")
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    writer.writeheader()

    rows = []
    n_done = 0
    with ThreadPoolExecutor(max_workers=NUM_WORKERS) as pool:
        futures = {pool.submit(run_point, slew, cload, corner): (corner, slew, cload)
                   for corner, slew, cload in points}
        for fut in as_completed(futures):
            corner, slew, cload = futures[fut]
            n_done += 1
            values = fut.result()
            row = _values_to_row(corner, slew, cload, values)
            rows.append(row)
            writer.writerow(row)
            csv_file.flush()
            print(f"[{n_done}/{total}] done: corner={corner} slew={slew*1e12:.0f}ps cload={cload*1e15:.0f}fF", flush=True)

    csv_file.close()
    print(f"\nDone. {len(rows)} points written to {out_csv}")

    # Also emit one NLDM-style pivoted table per corner/metric for readability
    for corner in CORNERS:
        corner_rows = [r for r in rows if r["corner"] == corner]
        for metric in ["tpHL_ps", "tpLH_ps"]:
            table_path = os.path.join(RESULTS_DIR, f"nldm_{corner}_{metric}.csv")
            with open(table_path, "w", newline="") as f:
                w = csv.writer(f)
                w.writerow(["slew_ps\\cload_fF"] + [str(c) for c in LOADS_F])
                for slew in SLEWS_S:
                    line = [str(slew * 1e12)]
                    for cload in LOADS_F:
                        match = [r for r in corner_rows
                                 if abs(r["slew_ps"] - slew * 1e12) < 1e-6
                                 and abs(r["cload_fF"] - cload * 1e15) < 1e-6]
                        line.append(str(match[0][metric]) if match else "NaN")
                    w.writerow(line)
    print(f"NLDM pivot tables written to {RESULTS_DIR}/nldm_<corner>_<metric>.csv")


if __name__ == "__main__":
    main()
