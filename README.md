# BEARX Toolbox

**Note:** for old BEAR notes, please go to [BEAR5 readme](./BEAR5doc.md)

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

You can install BEAR directly from the [Add-Ons panel in MATLAB](https://uk.mathworks.com/help/matlab/matlab_env/get-add-ons.html). Go to `HOME > Add Ons`, search for BEAR and install the toolbox. Alternatively, follow the steps below to install it from GitHub.

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

This is aimed at those people wanting to develop BEAR further. Clone this repository from within MATLAB and then open the Project with:

```matlab 
openProject('bear.prj')
```

Opening the MATLAB project will shadow the installed version of BEAR as long as the project is open, once the project is shut down, the installed version will again be default version. To check which version of BEAR is currently running, you can run:

```>> ver('bear')```

### Building from source

Clone the repository and open the project

```matlab
% 1. Extract the archive somewhere, then in MATLAB:
openProject('bear.prj')

% 2. Build
buildtool archive -skip check

% 3. Install
matlab.addons.install("releases/BEARtoolbox.mltbx", "overwrite", true)

% 4. Launch the GUI app
BEAR6
```

## Layout

Extract anywhere. The folders below MUST stay siblings (tutorials, GUI examples and the feature test suite use relative `../BEARX-Toolbox/` paths):

```
BEARX-Bundle/
├── BEARX-Toolbox/              ← patched toolbox (10 bugs fixed)
├── BEARX-tutorials/            ← tutorial scripts (legacy/obsolete material archived under _legacy/)
├── BEARX-GUI-Examples/         ← GUI example projects (incl. new test_VAR_* identification examples)
├── tests/                      ← full-feature regression suite on synthetic data
└── README.md                   ← this file

```matlab
gui.start    % fresh session (resets configuration)
gui.resume   % resume a previous session
```

## Examples
For scripting examples [BEARX tutorials](./BEARX-tutorials/BEARXtutorials.md)
For GUI examples BEARX-GUI-Examples

## Platform support

Tested on **Windows 10/11** (MATLAB R2021a - R2026a).

**Linux / Linux containers (Cloudera CML)** are intended to be supported, including case-sensitive filesystem handling required in container environments. In practice, support is generally good but may still be less stable than Windows in some setups.


## License
Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software "the Bayesian Estimation, Analysis and Regression (BEAR) toolbox".
[License](./BEAR%20End%20User%20Licence%20Agreement.pdf)