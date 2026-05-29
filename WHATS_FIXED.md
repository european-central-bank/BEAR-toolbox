# What's fixed - and what's still missing

Synthetic recap of the BEARX-Toolbox patches shipped in this bundle, plus the two known GUI gaps that are **not** patched here.

## Table of contents

- [1. Toolbox bugs fixed (10)](#1-toolbox-bugs-fixed-10)
  - [Blockers - crash on standard usage](#blockers---crash-on-standard-usage)
  - [Panel-specific - separable, ≥ 2 units](#panel-specific---separable--2-units)
  - [Latent / Windows-only](#latent--windows-only)
  - [Summary by area](#summary-by-area)
  - [Regression coverage](#regression-coverage)
  - [Companion fixes outside the toolbox](#companion-fixes-outside-the-toolbox)
- [2. Known GUI gaps - half-removed: deliberate or to be restored?](#2-known-gui-gaps---half-removed-deliberate-or-to-be-restored)
  - [2.1 - Mean-Adjusted VAR](#21---mean-adjusted-var)
  - [2.2 - Pseudo Out-of-Sample forecast evaluation](#22---pseudo-out-of-sample-forecast-evaluation)
- [3. What's new in the bundle (besides the toolbox patches)](#3-whats-new-in-the-bundle-besides-the-toolbox-patches)
  - [3.1 - New identification examples in `BEARX-GUI-Examples-master/`](#31---new-identification-examples-in-bearx-gui-examples-master)
  - [3.2 - Full-feature regression suite on synthetic data: `bearx_feature_tests/`](#32---full-feature-regression-suite-on-synthetic-data-bearx_feature_tests)
  - [3.3 - Tutorial regression runner: `test_run_Xtutorials.m`](#33---tutorial-regression-runner-test_run_xtutorialsm)
  - [3.4 - Tutorial cleanup: `_legacy/` archive](#34---tutorial-cleanup-_legacy-archive)


## 1. Toolbox bugs fixed (10)


### Blockers - crash on standard usage

| Symptom (what the user sees) | # | File | Root cause | Fix |
|---|---|---|---|---|
| Any `model.ReducedForm(...)` or `bear6.runFromConfig(...)` fails with `MATLAB:functionValidation:NotAClass`. | **1** | `+model/@ReducedForm/ReducedForm.m` | Constructor validator references non-existent class `estimator.Base` (real class = `base.Estimator`). | Change argument type to `base.Estimator`. |
| **Every** `Chartpack` plot crashes with `MATLAB:TooManyInputs`, even with defaults. | **2** | `+visual/Chartpack.m` | `Chartpack.plot()` forwards `plotFunc` / `barStyle` to `tablex.plot` which doesn't accept them; uses `"axes"` instead of `"axesHandle"`. | Dispatch on `PlotFunc`: `@plot` → `tablex.plot`; else → `tablex.drawChart`. Fold `BarStyle` into `PlotSettings` for `@bar`. Fix the `"axes"` kwarg. |
| `BetaTV` crashes at init regardless of project. | **4** | `+base/+estimator/BetaTV.m` | Declares `CanHaveDummies = true` but `initializeSampler` only accepts 2 args. All sibling SV/TV estimators have `false`. | Set `CanHaveDummies = false`. |
| All 7 FAVAR Twostep estimators crash with `MATLAB:badsubscript` at sampler init. | **10** | 7 files in `+factorTwostep/+estimator/` | `EstimatorSettings.update()` sizes `Exogenous`/`Lambda4`/`Autoregression` for `numEndo` only; FAVAR Twostep priors index up to `numEndo + numFactors`. Plus typo `HeteroskedasticityAutoRegressionMean` in `RandomInertiaSVFAVAR.m`. | 10-line pad block (identical across 7 files) after `bear.olsvar(FY, ...)` extending the three settings to factor dimensions (`Exogenous=false`, `AR=0`, `Lambda4` replicated). Typo fixed. |

### Panel-specific - separable, ≥ 2 units

| Symptom (what the user sees) | # | File | Root cause | Fix |
|---|---|---|---|---|
| Any panel ≥ 2 units + ConditionalForecast → `reshape` crash in `bear.tvcfsim1`. | **3** | `+base/@Structural/conditionalForecast.m` | Extracts `draw.beta` per unit on dim 2 instead of dim 3 (variable literally named `EXTRA_DIM_BUG` + TODO from the author). The other 14 call-sites use dim 3. | Rename `EXTRA_DIM_BUG = 2` → `EXTRACT_DIM = 3`. |
| `ZellnerHongPanel` / `HierarchicalPanel` + ConditionalForecast → same reshape crash. | **6** | `+separable/+estimator/PlainDrawersMixin.m` | `conditionalDrawer` stores units in dim 2; sibling drawers store them in dim 3. | Reshape `sample.beta` to push units to dim 3 before `wrap(...)`. |
| Conditions-only conditional forecasts (no plan) impossible - `cellfun` crashes on `[]`. | **7** | `+base/@Structural/conditionalForecast.m` | `cfconds`/`cfshocks`/`cfblocks` only built `if hasPlan`. | Always build the three CF arrays. Independent `~isempty(...)` guards downstream. |
| Prefixed plans on separable panel → `Unrecognized field name "US_DEM"`. | **8** | `+conditional/createShocksCF.m` + `+base/@Structural/conditionalForecast.m` | Dictionary built from `SeparableShockNames` (unprefixed `"DEM"`); plans use prefixed names (`"US_DEM"`). | Dictionary now from `meta.ShockNames` (always prefixed). Per-unit offset `cfshocks{k} - (unit-1)*numShockConcepts` after slicing. |
| Separable panel with simultaneous shocks on multiple units at the same period → opaque crash in `shocksim6:45`. Hits the shipped `SeparablePanel/` GUI example. | **9** | `+base/@Structural/conditionalForecast.m` | `cfblocks` numbered globally; after per-unit slicing each unit gets gappy numbering. | Rebuild `cfblocks` per-unit via `conditional.createBlocksCF(per-unit cfconds, per-unit cfshocks)`. Block numbers restart at 1. |

### Latent / Windows-only

| Symptom (what the user sees) | # | File | Root cause | Fix |
|---|---|---|---|---|
| Latent on Linux/macOS; on Windows, triggered after a toolbox cache rebuild → `default value uses an instance of itself`. Irrecoverable without rename. | **5** | `+base/+estimator/Settings.m` → `EstimatorSettings.m` (50 files touched) | Name clash: class `Settings.m` + package `+settings/` in same namespace. On Windows (case-insensitive FS) MATLAB confuses the two. | Rename parent class to `EstimatorSettings`. Case-sensitively update all 49 references `base.estimator.Settings` → `base.estimator.EstimatorSettings`. Package `+settings/` untouched. |

### Summary by area

| Area | Bugs | Symptom |
|---|---|---|
| `ReducedForm` construction | 1 | Argument validation error |
| Plotting (`Chartpack`) | 2 | Systematic `TooManyInputs` |
| `BetaTV` estimator | 4 | Init crashes |
| FAVAR Twostep (7 estimators) | 10 | `badsubscript` at sampler init |
| `conditionalForecast` (base.Structural) | 3, 6, 7, 8, 9 | Five distinct ways to crash a panel conditional forecast |
| Settings name clash (Windows) | 5 | Latent crash after cache rebuild |

**Total**: 10 bugs, ~11 source files patched (the Bug 5 rename mechanically touches 50 more).



### Companion fixes outside the toolbox

To make tutorials and GUI examples actually run on top of the patched toolbox, a few non-toolbox fixes were also applied (lower priority; flagged with `% PATCH:` comments where applicable):

- **`BEARX-tutorials-master/`** (4 scripts edited): commented `plan=[]` blocks that hit the conditional-forecast `cellfun` crash; added `exogenousFrom="conditions"` where required; switched separable-panel plans from prefixed (`"US_DEM US_POL"`) to unprefixed (`"DEM POL"`) shock names (separable.Meta strips the unit prefix); replaced `tablex.plot(..., plotFunc="bar")` by `tablex.drawChart(@bar, ...)`. Affected: `XConditionalForecasts.m`, `XConditionalForecastsPanel.m`, `XPanelNoCrossSectionsOneCountry.m`, `XModelsPanel.m`. 22 stale/legacy files moved to `_legacy/`.
- **`BEARX-GUI-Examples-master/`**: regenerated the missing `master.m` for `PlainTimeInvariant/` (upstream shipped the project without it) by re-running the GUI Assemble step; added a no-op `+gui/returnFromCommandWindow.m` shim so generated `master.m` scripts terminate cleanly outside the BEARX app; added the 5 new `test_VAR_*` projects covering identification schemes (see §3.1).

## 2. Known GUI gaps - half-removed: deliberate or to be restored?

Two BEAR6 features present in the legacy BEAR app appear only partially in BEAR6. **Open question for the ECB team: was this intentional, or should they be re-wired?**

### 2.1 - Mean-Adjusted VAR

Villani (2009) steady-state prior: puts the prior directly on the long-run means $\psi$ rather than on the intercepts $-$ the natural choice when the modeller has firm beliefs about long-run averages (e.g. inflation anchored at a target). **No other BEAR6 estimator offers this specification.**

Status: code exists (`bearing/+mean/+estimator/MeanAdjusted.m`, fully usable from a script), but **not wired in the GUI** (absent from `gui/forms/module/mapping.json`). Quick fix would be one line in `mapping.json` + a Meta sub-page for the steady-state spec.

### 2.2 - Pseudo Out-of-Sample forecast evaluation

Rolling-window backtest: re-estimate on $[1,t]$, forecast $\hat{y}_{t+1|t..t+h|t}$, compare to realised, report RMSFE / MAFE / log-score / CRPS per horizon. Standard step before publishing forecasts. Legacy BEAR had it (`BASEsettings.Feval`, `+bear/bvarfeval.m`); BEAR6 has **no equivalent** ($0$ hits for `feval` / `window_size` under `bearing/`, absent from the 8-task list).

Matters more, not less, under full Bayesian: hyperparameter tuning (Minnesota $\lambda_1, \lambda_2, \dots$) is typically pinned by OOS log-score (Giannone-Lenza-Primiceri 2015). Re-adding would naturally extend to CRPS / log-score / PIT given that BEAR6 already stores full predictive draws.

## 3. What's new in the bundle (besides the toolbox patches)

### 3.1 - New identification examples in `BEARX-GUI-Examples-master/`

Five new GUI projects added on top of the four shipped by ECB (`PlainTimeInvariant/`, `SeparablePanel/`, `Threshold/`, `MixedFrequency/`), covering identification schemes the upstream examples did not exercise:

| Project | Purpose |
|---|---|
| `test_VAR_reducedform/` | Plain reduced-form VAR, no identification - sanity baseline |
| `test_VAR_Cholesky_iden/` | Recursive Cholesky identification (standard CEE ordering) |
| `test_VAR_shortrun_UNDER_iden/` | Under-identified short-run zero restrictions via `InstantZeros` (< n(n−1)/2 zeros, sampled rotations) |
| `test_VAR_sign_iden/` | Sign restrictions via `IneqRestrict` (impact + horizon, sign + relative magnitude) |
| `test_VAR_generalized_iden/` | Full DSL via `GeneralRestrict` (signs + relative magnitudes + FEVD constraints + long-run / Blanchard-Quah style restrictions) |

Each project is a full GUI snapshot (`forms/*.json`, `tables/*.xlsx`, `master.m`) - opening the folder in BEAR6 → *Existing Estimation* lets a user inspect or modify the configuration interactively.

### 3.2 - Full-feature regression suite on synthetic data: `bearx_feature_tests/`

End-to-end harness exercising every BEARX GUI feature against synthetic data generated on the fly (no external CSV / Excel dependency). **70 PASS / 0 FAIL / 0 SKIP** out of 70 cases on the patched toolbox, ~50 s runtime. 9 suites covering all GUI categories:

| Suite | Coverage | Cases |
|---|---|---|
| `suite01_plainEstimators` | 6 plain BVARs (NW, Minnesota, IndNW, ND, Flat, Ordinary) | 6 |
| `suite02_tvSvEstimators` | BetaTV, GeneralTV + 8 SV variants (Carriero / CogleySargent / RandomInertia / CCMM×3 / LargeShock×2) | 10 |
| `suite03_panelEstimators` | 4 separable + 2 cross panels | 6 |
| `suite04_favarEstimators` | 5 one-step + 10 two-step FAVAR | 15 |
| `suite05_specialEstimators` | Threshold, MixedFrequency, MeanAdjusted | 3 |
| `suite06_dummies` | 4 prior dummies × (smoke + semantic) | 8 |
| `suite07_identification` | Cholesky, InstantZeros, IneqRestrict, GeneralRestrict | 5 |
| `suite08_tasks` | 8 GUI tasks + 3 file outputs (XLS / CSV / MAT) | 11 |
| `suite09_options` | NumSamples, Percentiles, StochasticResiduals, Intercept/Order, IdentificationHorizon | 6 |

Ships in this bundle as the sibling folder `bearx_feature_tests/` (also mirrored at `Camille.Souffron/bearx-feature-tests`). Bugs 1, 3, 4, 6, 7, 8, 9, 10 are auto-detected when run against an unpatched toolbox.

### 3.3 - Tutorial regression runner: `test_run_Xtutorials.m`

Inside `BEARX-tutorials-master/`, the `test_run_Xtutorials.m` script iterates over every `X*.m` tutorial (`XConditionalForecasts`, `XPanelNoCrossSections`, `XThresholdTest`, `XTVModels`, …) and reports PASS / FAIL per tutorial against a given toolbox. Companion to `test_bear_bugs.m` (3 isolated bug reproducers) and `realworld_test.m` (end-to-end CSV → estimate → plot → forecast).

### 3.4 - Tutorial cleanup: `_legacy/` archive

22 obsolete files (legacy kwargs `endogenous=`, `model.Meta(...)`, removed `+meanAdjusted/` package, `addpath ../sandbox`, old `.mlx` Live Scripts) moved to `BEARX-tutorials-master/_legacy/`. Root now contains only what runs against BEAR6: 9 modern `test*.m` + matching `t*.mlx`, plus the runners above and the `X*.m` tutorials.
