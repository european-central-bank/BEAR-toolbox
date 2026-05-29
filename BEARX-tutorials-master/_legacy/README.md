# Legacy tutorial scripts (pre-BEAR 6 API)

These scripts use the **old keyword-argument names** (e.g. `endogenous=`,
`units=`, `exogenous=`) that the BEAR 6 `Meta` constructors no longer
accept. The expected names are now `endogenousNames=`, `unitNames=`,
`exogenousNames=`, etc.

Kept here for reference / pedagogical history only. They are **not**
executed by `run_tutorials.m` or `run_extra_tests.m`.

| File | Issue | BEAR 6 equivalent |
|---|---|---|
| `testBase.m` | `base.Meta(endogenous=…, units=…)` — panel structure no longer fits in `base.Meta` | see `XPanelNoCrossSections.m` / `separable.Meta` |
| `introCommonTasks.m` | `base.Meta(endogenous=…)` | see `XDummies.m` / `Dummies.m` |
| `exactZeroRestrictions.m` | `model.Meta(endogenous=…)` | see `XInstantZeroRestrictions.m` |
| `exactZeroRestrictions_lj.m` | same as above | see `XInstantZeroRestrictions.m` |

`test_FAVAR.m` and `testnw.m` were both rewritten (and moved back to the
root) to use `factorTwostep.*` and `base.*` respectively — the same paths
the BEARX GUI uses. They bypass the broken `favar.Meta` / `minnesota.Meta`
forwarding (which extend the archived `+baseWithDummies~/` superclass).

## Legacy MATLAB Live Scripts (`.mlx`)

The repo also shipped 26 `.mlx` files (MATLAB Live Scripts — interactive
notebooks with narrative text + code + outputs). After auditing the
extracted code of each:

- The 9 modern Live Scripts `t1_baseEstimators.mlx`, `t2a_factorTwostep.mlx`,
  `t2b_factorOnestep.mlx`, `t3a_panelNoCrossSections.mlx`,
  `t3b_panelCrossSections.mlx`, `t4_threshold.mlx`, `t5_CCMM.mlx`,
  `t6_mixedFrequency.mlx`, `t7_meanAdjusted.mlx` use the BEAR 6 API
  (`import base.*` / `import factorTwostep.*` / etc., `endogenousNames=`,
  `shockNames=` or — for panel packages — the canonical
  `endogenousConcepts=` / `shockConcepts=`). They mirror the
  `test1_…` / `test5_…` plain-text scripts that all pass. **Kept at root.**

- The remaining 17 `.mlx` files use the pre-BEAR 6 API: `model.Meta(...)`
  (the `model.*` package no longer exists — it was renamed to `base.*`),
  `addpath ../sandbox` (the sandbox folder is gone), and in `Dummies.mlx`
  `dummies.SumCoefficients` (renamed to `dummies.SumCoeff`). Archived
  here:

  | File | Marker |
  |---|---|
  | `CCMMSVModel.mlx`, `CCMMSVOModel.mlx`, `CCMMSVOTModel.mlx` | `model.Meta(...)` |
  | `conditionalForecasts.mlx` | `model.Meta(...)` |
  | `Dummies.mlx` | `model.Meta(...)`, `dummies.SumCoefficients`, `addpath ../sandbox` |
  | `exactZeroRestrictions.mlx` | `model.Meta(...)` |
  | `FAVARtest_new.mlx` | `model.Meta(...)` |
  | `genlargeshockSV.mlx`, `largeshockSV.mlx` | `model.Meta(...)` |
  | `introCommonTasks.mlx` | `model.Meta(...)`, `addpath ../sandbox` |
  | `Panel_cross_sectional.mlx`, `PanelCrossSections.mlx` | `model.Meta(...)` |
  | `Panel_no_cross_sections.mlx`, `PanelNoCrossSections.mlx`, `PanelNoCrossSectionsOneCountry.mlx` | `model.Meta(...)` |
  | `SVModels.mlx`, `TVModels.mlx` | `model.Meta(...)` |

  These predate the API refactor and have no maintained `.m` counterpart at
  the root. The equivalent functionality is covered by the modern `t*.mlx`
  / `X*.m` / `test*.m` tutorials.

`setup.m` was deleted (it referenced the `+meanAdjusted/` package which
does not exist in BEAR 6 — only `+mean/` remains, which is a different
package).
