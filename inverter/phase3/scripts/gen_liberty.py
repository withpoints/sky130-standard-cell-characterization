#!/usr/bin/env python3
"""Generate Liberty (.lib) files for the INV cell, one per corner, from the
phase-3 characterization CSV (inv_characterization.csv)."""
import csv
import os

RESULTS_DIR = os.path.expanduser("~/projects/vlsi_phase3/results")
CSV_PATH = os.path.join(RESULTS_DIR, "inv_characterization.csv")
OUT_DIR = os.path.expanduser("~/projects/vlsi_phase3/lib")

SLEWS_PS = [20.0, 50.0, 100.0, 200.0, 500.0]
LOADS_FF = [1.0, 5.0, 10.0, 25.0, 50.0]
CORNERS = ["tt", "ss", "ff"]

# Input pin capacitance: sum of parasitic caps touching node G in the PEX
# extraction (C0 Out-G=0.03815fF + C1 VDD-G=0.14233fF + C4 G-VSS=0.31531fF)
PIN_CAP_A_FF = 0.03815 + 0.14233 + 0.31531  # = 0.49579 fF

AREA_UM2 = 5.805  # 2.150 x 2.700 um, from inverter.mag


def load_data():
    rows = []
    with open(CSV_PATH) as f:
        for r in csv.DictReader(f):
            rows.append(r)
    return rows


def get_matrix(rows, corner, metric):
    """Return a 5x5 matrix [slew][load] for the given metric, in the CSV's
    native units (ps or fJ or pW)."""
    matrix = []
    for slew in SLEWS_PS:
        row_vals = []
        for load in LOADS_FF:
            match = [r for r in rows
                     if r["corner"] == corner
                     and abs(float(r["slew_ps"]) - slew) < 1e-3
                     and abs(float(r["cload_fF"]) - load) < 1e-3]
            if not match:
                raise ValueError(f"missing data for {corner} slew={slew} load={load}")
            row_vals.append(float(match[0][metric]))
        matrix.append(row_vals)
    return matrix


def fmt_matrix(matrix):
    lines = []
    for i, row in enumerate(matrix):
        vals = ", ".join(f"{v:.5f}" for v in row)
        term = ",\\" if i < len(matrix) - 1 else ""
        lines.append(f'      "{vals}"{term}')
    return "\n".join(lines)


def leakage_avg(rows, corner, column):
    vals = [float(r[column]) for r in rows if r["corner"] == corner]
    return sum(vals) / len(vals)


def gen_lib(rows, corner):
    tpHL = get_matrix(rows, corner, "tpHL_ps")
    tpLH = get_matrix(rows, corner, "tpLH_ps")
    tfall = get_matrix(rows, corner, "tfall_ps")
    trise = get_matrix(rows, corner, "trise_ps")
    e_hl = get_matrix(rows, corner, "e_hl_fJ")
    e_lh = get_matrix(rows, corner, "e_lh_fJ")
    # fall_power must be a positive energy per Liberty convention; e_hl came
    # out slightly negative (falling transitions draw ~0 net charge from
    # VDD -- see phase-3 notes), so floor at a small positive value.
    fall_power = [[max(abs(v), 1e-4) for v in row] for row in e_hl]
    rise_power = e_lh

    p_leak_lo = leakage_avg(rows, corner, "p_leak_lo_pW")
    p_leak_hi = leakage_avg(rows, corner, "p_leak_hi_pW")

    slew_idx = ", ".join(str(s) for s in SLEWS_PS)
    load_idx = ", ".join(str(l) for l in LOADS_FF)

    lib = f'''library(INV_{corner}) {{
  technology (cmos);
  delay_model : table_lookup;
  comment : "sky130 INV cell, {corner.upper()} corner, VDD=1.8V, T=27C -- generated from phase-3 characterization sweep";

  time_unit : "1ps";
  voltage_unit : "1V";
  current_unit : "1uA";
  pulling_resistance_unit : "1kohm";
  leakage_power_unit : "1pW";
  capacitive_load_unit(1, ff);

  nom_process : 1.0;
  nom_voltage : 1.8;
  nom_temperature : 27.0;

  /* matches the 50% delay / 10-90% transition points used in the
     phase-3 ngspice characterization measurements */
  input_threshold_pct_rise : 50.0;
  input_threshold_pct_fall : 50.0;
  output_threshold_pct_rise : 50.0;
  output_threshold_pct_fall : 50.0;
  slew_lower_threshold_pct_rise : 10.0;
  slew_lower_threshold_pct_fall : 10.0;
  slew_upper_threshold_pct_rise : 90.0;
  slew_upper_threshold_pct_fall : 90.0;

  lu_table_template(delay_template_5x5) {{
    variable_1 : input_net_transition;
    variable_2 : total_output_net_capacitance;
    index_1("{slew_idx}");
    index_2("{load_idx}");
  }}

  power_lut_template(power_template_5x5) {{
    variable_1 : input_net_transition;
    variable_2 : total_output_net_capacitance;
    index_1("{slew_idx}");
    index_2("{load_idx}");
  }}

  cell(INV) {{
    area : {AREA_UM2};

    pin(A) {{
      direction : input;
      capacitance : {PIN_CAP_A_FF:.5f};
    }}

    pin(Y) {{
      direction : output;
      function : "A'";
      timing() {{
        related_pin : "A";
        timing_sense : negative_unate;
        cell_fall(delay_template_5x5) {{
          values(\\
{fmt_matrix(tpHL)});
        }}
        fall_transition(delay_template_5x5) {{
          values(\\
{fmt_matrix(tfall)});
        }}
        cell_rise(delay_template_5x5) {{
          values(\\
{fmt_matrix(tpLH)});
        }}
        rise_transition(delay_template_5x5) {{
          values(\\
{fmt_matrix(trise)});
        }}
      }}
      internal_power() {{
        related_pin : "A";
        fall_power(power_template_5x5) {{
          values(\\
{fmt_matrix(fall_power)});
        }}
        rise_power(power_template_5x5) {{
          values(\\
{fmt_matrix(rise_power)});
        }}
      }}
    }}

    leakage_power () {{
      when : "A'";
      value : {p_leak_lo:.5f};
    }}
    leakage_power () {{
      when : "A";
      value : {p_leak_hi:.5f};
    }}
  }}
}}
'''
    return lib


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    rows = load_data()
    for corner in CORNERS:
        lib_text = gen_lib(rows, corner)
        out_path = os.path.join(OUT_DIR, f"inv_{corner}.lib")
        with open(out_path, "w") as f:
            f.write(lib_text)
        print(f"wrote {out_path}")


if __name__ == "__main__":
    main()
