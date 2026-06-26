# BEARX Toolbox

[![Test and Package BEAR](https://github.com/european-central-bank/BEAR-toolbox/actions/workflows/ci.yml/badge.svg?branch=BEAR6-staging)](https://github.com/european-central-bank/BEAR-toolbox/actions/workflows/ci.yml)

**Note:** for old BEAR notes, please go to [BEAR5 readme](./BEAR5doc.md)

## Table of Contents

- [Introduction](#Introduction)
  * [Structure of the repository](#Structure-of-the-repository)
- [Features](#Features)
- [Installing BEAR](#Installing-BEAR)
  * [For users](#For-BEAR-users)
  * [For developers](#For-developers)
  * [Building from source](#Building-from-source)
- [Getting started](#Getting-started)
  * [Examples](#Examples)
  * [Migration and Data Format](#Migration-and-Data-Format)
- [Documentation](#Documentation)
- [Platform support](#Platform-Support)
- [License](#License)

## Introduction

The BEARX Toolbox is a MATLAB toolbox for Bayesian estimation, analysis, and
reporting of vector autoregressive (VAR) models. BEARX is an extended version
of the original BEAR Toolbox (version 5), adding a new command-line interface
(CLI) and a new graphical user interface (GUI) while keeping the original BEAR
available as before.

### Structure of the repository

This repository is organized as follows.

```
BEARX/
├── BEARX-Toolbox/       ← Toolbox Files
├── BEARX-tutorials/     ← Tutorial files for running BEAR6
├── BEARX-GUI-Examples/  ← GUI example projects (incl. new test_VAR_* identification examples)
├── tests/               ← All Toolbox Tests
└── README.md            ← this file
```

All BEAR files that need to be installed by the end-users are located inside `BEARX-Toolbox` in four separate directories:

- `app` contains all the files related to the user interface for BEAR6 and BEAR5
- `bear` has all the core MATLAB functions and classes
- `doc` contains a set of PDFs with some of the BEAR documentation
- `replications` contains a set of Excel and settings files to replicate previous results from the literature in BEAR5

## Features

- A comprehensive range of Bayesian VAR estimators: plain (OLS, Minnesota,
  Normal-Wishart, …), time-varying, panel, factor-augmented (FAVAR),
  threshold, and mixed-frequency
- Structural identification via Cholesky decomposition, zero restrictions,
  sign restrictions, and generalized restrictions
- Forecasting (unconditional and conditional), impulse response functions,
  historical shock decomposition, and forecast error variance decomposition
- A transparent GUI that auto-generates editable MATLAB scripts — nothing
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
Once this file has been downloaded, you can double click it from MATLAB to install the toolbox. Or alternatively run:

```matlab 
matlab.addons.install('BEARToolbox.mltbx') 
```

### For developers

This is aimed at those people wanting to develop BEAR further. Clone this repository from within MATLAB and then open the Project with:

```matlab 
openProject('BEARX-Toolbox.prj')
```

Opening the MATLAB project will shadow the installed version of BEAR as long as the project is open, once the project is shut down, the installed version will again be default version. To check which version of BEAR is currently running, you can run:

```matlab 
>> bearroot 
```

### Building from source

Clone the repository and open the project

```matlab
% 1. Extract the archive somewhere, then in MATLAB:
openProject('BEARX-Toolbox.prj')

% 2. Build
buildtool archive

% 3. Install
matlab.addons.install("releases/BEARtoolbox.mltbx", "overwrite", true)

% 4. Launch the GUI app
BEAR6
```

## Getting Started

To get started with BEAR, the easiest is to run the BEAR6 app. For this either go to the toolstrip APPS and select `BEAR6`, or simpy run:

```matlab
BEAR6 
```

Alternatively, if you want to start a new session, you can simply run the following command. Note that BEAR will copy over some files, so it is recommended that you do it in an empty folder:

```matlab
gui.start    % fresh session (resets configuration)
```

To resume a previous session, move to the working directory and run:

```matlab
gui.resume   % resume a previous session
```

### Examples

For scripting examples [BEARX tutorials](./BEARX-tutorials/BEARXtutorials.md)
For GUI examples BEARX-GUI-Examples

### Migration and Data Format

For users migrating from BEAR 5, and for guidance on data structuring and variable labeling for different estimators, see [From BEAR5 to BEAR6 and data format](https://github.com/european-central-bank/BEAR-toolbox/wiki/From-BEAR5-to-BEAR6-and-data-format) in the wiki.

## Documentation

From GitHub, you can easily access the [Wiki](https://github.com/european-central-bank/BEAR-toolbox/wiki). Alternatively once you have BEAR installed or the project open you can run:

```matlab
beardoc 
```

## Platform support

Tested on **Windows 10/11** (MATLAB R2021a - R2026a).

**Linux / Linux containers (Cloudera CML)** are intended to be supported, including case-sensitive filesystem handling required in container environments. In practice, support is generally good but may still be less stable than Windows in some setups.


## License
Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software "the Bayesian Estimation, Analysis and Regression (BEAR) toolbox".
[License](./BEAR%20End%20User%20Licence%20Agreement.pdf)
