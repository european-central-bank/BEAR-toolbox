# BEARX 6 Bundle (patched V1)

This archive contains a **patched BEARX toolbox** with 10 upstream bugs fixed, plus the tutorials and GUI examples preconfigured to use it out of the box.

## Layout

Extract anywhere. The folders below MUST stay siblings (tutorials, GUI examples and the feature test suite use relative `../BEARX-Toolbox/` paths):

```
BEARX-Bundle/
├── BEARX-Toolbox/              ← patched toolbox (10 bugs fixed)
├── BEARX-tutorials-master/     ← tutorial scripts (legacy/obsolete material archived under _legacy/)
├── BEARX-GUI-Examples-master/  ← GUI example projects (incl. new test_VAR_* identification examples)
├── bearx_feature_tests/        ← full-feature regression suite on synthetic data (70/70 PASS)
└── README.md                   ← this file
```

## Platform support

Tested on **Windows 10/11** (MATLAB R2025b). All 10 toolbox patches verified there, including Bug 5 which was the original Windows-specific trigger (the `Settings` / `+settings` namespace clash).

**Linux / Linux containers (Cloudera CML)** — supported via two additional patches included in this bundle:
1. `gui.resume`: on case-sensitive filesystems (ext4), MATLAB's `copyfile` can drop one of two case-different siblings (e.g. `Minnesota.html` vs `minnesota.html`) when copying the GUI HTML folder; switched to `cp -RPp` on Linux to preserve all files. PascalCase HTML variants (`Minnesota.html`, `SumCoeff.html`, `LongRun.html`, `InitialObs.html`, `GeneralRestrict.html`) are also shipped as real files alongside the lowercase ones.
2. `chartpack.printFiguresPDF`: each `exportgraphics` call is now wrapped in `try/catch` with the figure temporarily set to `Visible='off'`, preventing the htmlviewer-triggered `onCleanup` error in `matlab.graphics.internal.export.Exporter` from aborting `master.m` when run from the GUI in a headless/container context.

With these two patches, the GUI launches and full `master.m` runs (forecasts, FEVD, contributions, PDFs) complete end-to-end on Cloudera CML.

## Install - step by step

```matlab
% 1. Extract the archive somewhere, then in MATLAB:
cd('path\to\BEARX-Toolbox')
openProject('BEARX-Toolbox.prj')

% 2. Build
buildtool -skip check

% 3. Install
matlab.addons.install("releases\BEARtoolbox.mltbx", "overwrite", true)

% 4. Launch the GUI app
BEAR6
```
