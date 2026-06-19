# BEARX tutorials

Tutorial scripts for the BEARX Toolbox (BEAR 6, MATLAB).

## Layout requirement

These scripts find the toolbox via a **relative path**. Extract this
folder and `BEARX-Toolbox/` **side-by-side** in the same parent:

```
parent/
├── BEARX-tutorials-master/   ← this folder
└── BEARX-Toolbox/
    └── tbx/bear/bearing/
```

so once the two folders are next to each other, you can `cd` into
`BEARX-tutorials-master/` and run any script directly - no install,
no environment variable, no manual `addpath`. If your toolbox folder
has a different name (e.g. `BEARX-Toolbox-PATCHED`), rename it
`BEARX-Toolbox` or edit the two lines.

## How to run

In MATLAB:

```matlab
cd path/to/BEARX-tutorials-master
test1_baseEstimators   % or any other script
```

## Scripts

### `testN_*.m` - numbered tutorials, one per model family

| Script | Covers |
|---|---|
| `test1_baseEstimators.m` | plain BVAR (`base.*`) |
| `test2a_factorTwostep.m` | FAVAR two-step (`factorTwostep.*`) |
| `test2b_factorOnestep.m` | FAVAR one-step (`factorOnestep.*`) |
| `test3a_panelNoCrossSections.m` | panel without cross-sections (`separable.*`) |
| `test3b_panelCrossSections.m` | panel with cross-sections (`cross.*`) |
| `test4_threshold.m` | threshold VAR (`threshold.*`) |
| `test5_CCMM.m` | CCMM with outliers / SV / t-shocks (`base.*`) |
| `test6_mixedFrequency.m` | mixed-frequency VAR (`mixed.*`) - reduced-form only, see header |
| `test7_meanAdjusted.m` | mean-adjusted BVAR with trends (`mean.*`) |

Each `testN_*.m` has a companion `tN_*.mlx` MATLAB Live Script with
narrative text and pre-rendered outputs.

### `X*.m` - additional task-focused tutorials

| Script | Topic |
|---|---|
| `XDummies.m` | prior dummy observations (`dummies.*`) |
| `XInstantZeroRestrictions.m` | exact zero restrictions |
| `XTVModels.m` | time-varying parameters |
| `XThresholdTest.m` | threshold model |
| `XPanelNoCrossSections.m`, `XPanelCrossSections.m`, `XPanelNoCrossSectionsOneCountry.m` | panel variants |
| `XModelsPanel.m` | panel estimators overview |
| `XConditionalForecasts.m`, `XConditionalForecastsPanel.m` | conditional forecasts |

### Other

- `testnw.m`, `test_FAVAR.m` - sandbox scripts rewritten to use the
  same packages the BEARX GUI uses (`base.*`, `factorTwostep.*`).
- `test_bear_bugs.m` - standalone harness reproducing 8 BEAR 6 bugs.
- `Dummies.m` - standalone reduced-form + Cholesky demo with dummies.
- `realworld_test.m` - end-to-end smoke test on a real-world dataset.
- `_legacy/` - pre-BEAR 6 scripts and Live Scripts archived for
  reference (see `_legacy/README.md`).
