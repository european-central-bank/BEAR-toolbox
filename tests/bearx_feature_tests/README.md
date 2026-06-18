# BEARX feature test suite

Comprehensive automated tests for every GUI-exposed feature of BEARX
(estimators, dummies, identifications, tasks, option semantics) using
synthetic datasets so it runs from scratch on any machine.

**Current run (2026-05-29):** **70 PASS / 0 FAIL / 0 SKIP** out of 70 cases
(~50 s, default `numSamples=50`), against `BEARX-Toolbox-PATCHED/`.

## Layout

```
bearx_feature_tests/
├── run_all.m                        ← orchestrator (runs every suite, prints summary, writes results.json)
├── tutil_runCase.m                  ← single-case wrapper: try/catch + timing + identifier + optional tag
├── tutil_report.m                   ← pretty-printer + JSON writer (16-wide tag column)
├── tutil_synthVAR.m                 ← synth plain VAR CSV (3 endo + 1 exo)
├── tutil_synthPanel.m               ← synth panel CSV (3 units × 3 concepts + Oil)
├── tutil_synthThreshold.m           ← synth threshold CSV (+ indicator)
├── tutil_synthMixed.m               ← synth mixed-frequency CSV (monthly + quarterly)
├── tutil_synthFAVAR.m               ← synth FAVAR CSV (3 endo + 8 reducible + Oil)
├── tutil_synthMean.m                ← synth Mean-Adjusted (trends)
├── tutil_synthMonthlyCOVID.m        ← synth 32y monthly VAR with COVID-style Σ jump + outliers (CCMM/LargeShock)
├── tutil_dataDir.m                  ← returns abs path of data/ (created on first call)
├── suite01_plainEstimators.m        ← 6 plain BVARs
├── suite02_tvSvEstimators.m         ← 2 TV + 8 SV (quarterly + monthly COVID-style)
├── suite03_panelEstimators.m        ← 4 separable + 2 cross
├── suite04_favarEstimators.m        ← 5 onestep + 10 twostep
├── suite05_specialEstimators.m      ← Threshold + MixedFrequency + MeanAdjusted
├── suite06_dummies.m                ← 4 dummies + 4 semantic checks (posterior shrinks toward prior)
├── suite07_identification.m         ← Cholesky (±reorder) + InstantZeros + IneqRestrict + GeneralRestrict
├── suite08_tasks.m                  ← 8 GUI tasks + XLS/CSV/MAT file outputs
└── suite09_options.m                ← NumSamples / Percentiles / StochasticResiduals / Intercept / Order / IdentificationHorizon
```

## Usage

From MATLAB, with `BEARX-Toolbox-PATCHED/` on the path:

```matlab
cd path/to/bearx_feature_tests
results = run_all                       % run everything (~50 s with default numSamples=50)
results = run_all('only', "suite06")    % run a single suite
results = run_all('numSamples', 50)     % override sample count
```

To run one suite directly without the orchestrator:

```matlab
suite06_dummies
```

## Defaults (kept low so the whole thing finishes in a coffee break)

- `numSamples = 50` for every reduced-form / structural sample
- `numCandidates = 20` for sign / general restrictions
- Synthetic data: 120 quarters (1990-Q1 → 2019-Q4), stable VAR(2)
- All data in `data/` (regenerated on each suite call via `rng(0)` → deterministic)

Bump `numSamples` to 1000+ in `run_all.m` for production validation.

## Output

```
results.json          ← per-case: name, status (PASS/FAIL/SKIP), identifier, elapsed_s, suite
results.log           ← human-readable trace
```

Each case is one row. A suite fails if ≥ 1 case fails. The orchestrator's exit
struct has fields `nPass`, `nFail`, `nSkip`, `bySuite`, `failures` (array of
`{suite, case, identifier, message}`).

## Coverage map (vs GUI feature inventory)

| GUI area              | Suite     | Cases | Status |
|-----------------------|-----------|-------|--------|
| Plain estimators (6)  | suite01   | 6     | 6/6 PASS |
| TV (2) + SV (8)       | suite02   | 10    | 10/10 PASS (incl. CCMM + LargeShock on monthly COVID-style data) |
| Panel sep (4) + cross (2) | suite03 | 6   | 6/6 PASS |
| FAVAR 1-step (5) + 2-step (10) | suite04 | 15 | 15/15 PASS (requires BEARX-Toolbox-PATCHED) |
| Threshold + MixedFreq + MeanAdj | suite05 | 3 | 3/3 PASS |
| Dummies (4) + semantic | suite06  | 8 | 8/8 PASS |
| Identifications (5) + semantic | suite07 | 5 | 5/5 PASS (incl. GeneralRestrict DSL) |
| Tasks (8) + files (3) | suite08   | 11    | 11/11 PASS |
| Option semantics      | suite09   | 6     | 6/6 PASS |
| **TOTAL**             |           | **70** | **70 PASS / 0 FAIL / 0 SKIP** |

## Tag system

`tutil_runCase(suite, name, fn, tag)` supports an optional 4th `tag` argument
printed in the results column. Reserved tags used historically:

- `<NOT IN GUI>`  — feature works via script API but is not wired into the GUI yet (e.g. MeanAdjusted)
- `<DATA-SPECIFIC>` — feature requires a specific data shape (e.g. COVID turning-point)
- `<UNDOCUMENTED>` — settings/hyperparameters not documented in BEAR (currently empty)
- `<BEAR BUG>`    — toolbox-side bug, not a test failure (currently empty after the suite04 patches)
