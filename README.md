# BEARX Toolbox

Note: for old BEAR notes, please go to [BEAR5 readme](./BEAR5doc.md)

The BEARX Toolbox is a Matlab toolbox for Bayesian estimation, analysis, and
reporting of vector autoregressive (VAR) models. BEARX is an extended version
of the original BEAR Toolbox (version 5), adding a new command-line interface
(CLI) and a new graphical user interface (GUI) while keeping the original BEAR
available as before.

## Features

- A comprehensive range of Bayesian VAR estimators: plain (OLS, Minnesota,
  Normal-Wishart, …), time-varying, panel, factor-augmented (FAVAR),
  threshold, and mixed-frequency
- Structural identification via Cholesky decomposition, zero restrictions,
  sign restrictions, and generalized restrictions
- Forecasting (unconditional and conditional), impulse response functions,
  historical shock decomposition, and forecast error variance decomposition
- A transparent GUI that auto-generates editable Matlab scripts — nothing
  runs behind the scenes

## Installation

### For BEAR users

__**From MATLAB**__

You can install BEAR directly from the [Add-Ons panel in MATLAB]('https://uk.mathworks.com/help/matlab/matlab_env/get-add-ons.html'). Go to `HOME > Add Ons`, search for BEAR and install the toolbox. Alternatively, follow the steps below to install it from GitHub.

<br/><br/>
![double click on bear.mltbx to install the toolbox](/images/Install.PNG "Manual install from MATLAB")
<br/><br/>

__**From GitHub**__

Download the latest `BEARToolbox.mltbx` file that you will find under the Releases section on the right. 
<br/><br/>
![release location in GitHub](/images/releaseLoc.png "release location")
<br/><br/>
Once this file has been downloaded, you can double click it from MATLAB to install the toolbox.

### For developers

This is aimed at those people wanting to develop BEAR further. Clone this repository repository from within MATLAB and then open the Project with:

```matlab 
openProject('bear.prj')
```

Opening the MATLAB project will shadow the installed version of BEAR as long as the project is open, once the project is shut down, the installed version will again be default version. To check which verison of BEAR is currently running, you can run:

```>> ver('bear')```

### Building rom source

Clone the repository and open the project

```matlab
% 1. Extract the archive somewhere, then in MATLAB:
openProject('BEARX-Toolbox.prj')

% 2. Build
buildtool archive -skip check

% 3. Install
matlab.addons.install("releases\BEARtoolbox.mltbx", "overwrite", true)

% 4. Launch the GUI app
BEAR6
```

## Layout

Extract anywhere. The folders below MUST stay siblings (tutorials, GUI examples and the feature test suite use relative `../BEARX-Toolbox/` paths):

```
BEARX-Bundle/
├── BEARX-Toolbox/              ← patched toolbox (10 bugs fixed)
├── BEARX-tutorials-master/     ← tutorial scripts (legacy/obsolete material archived under _legacy/)
├── BEARX-GUI-Examples-master/  ← GUI example projects (incl. new test_VAR_* identification examples)
├── bearx_feature_tests/        ← full-feature regression suite on synthetic data (70/70 PASS)
└── README.md                   ← this file

```matlab
gui.start    % fresh session (resets configuration)
gui.resume   % resume a previous session
```

## Platform support

Tested on **Windows 10/11** (MATLAB R2021a - R2026a). All 10 toolbox patches verified there, including Bug 5 which was the original Windows-specific trigger (the `Settings` / `+settings` namespace clash).

**Linux / Linux containers (Cloudera CML)** — supported via two additional patches included in this bundle:
1. `gui.resume`: on case-sensitive filesystems (ext4), MATLAB's `copyfile` can drop one of two case-different siblings (e.g. `Minnesota.html` vs `minnesota.html`) when copying the GUI HTML folder; switched to `cp -RPp` on Linux to preserve all files. PascalCase HTML variants (`Minnesota.html`, `SumCoeff.html`, `LongRun.html`, `InitialObs.html`, `GeneralRestrict.html`) are also shipped as real files alongside the lowercase ones.
2. `chartpack.printFiguresPDF`: each `exportgraphics` call is now wrapped in `try/catch` with the figure temporarily set to `Visible='off'`, preventing the htmlviewer-triggered `onCleanup` error in `matlab.graphics.internal.export.Exporter` from aborting `master.m` when run from the GUI in a headless/container context.

With these two patches, the GUI launches and full `master.m` runs (forecasts, FEVD, contributions, PDFs) complete end-to-end on Cloudera CML.


## License
Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software "the Bayesian Estimation, Analysis and Regression (BEAR) toolbox".
[License](/tbx/doc/BEAR%20End%20User%20Licence%20Agreement.pdf)