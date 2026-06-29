| :information_source: This document is for BEAR 5 users only. BEAR 5 is installed alongside BEAR 6, but this guide does not apply to BEAR 6 workflows. |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|

[![View BEAR 5.2 on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/103370-bear-5-1)

| **GitHub<sup>&reg;</sup>&nbsp;Actions** |
|:----------------------------:|
|[![MATLAB](https://github.com/european-central-bank/BEAR-toolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/european-central-bank/BEAR-toolbox/actions/workflows/ci.yml)|

# The BEAR toolbox

## Table of Contents

- [Introduction](#Introduction)
  * [Structure of the repository](#Structure-of-the-repository)
- [Installing BEAR](#Installing-BEAR)
  * [For users](#For-users)
  * [For developers](#For-developers)
  * [For non-MATLAB users](#For-non-MATLAB-users)
- [Getting started](#Getting-started)
  * [Creating a settings object](#Creating-a-settings-object)
  * [Running BEAR from the command line](#Running-BEAR-from-the-command-line)
  * [Running BEAR interactively](#Running-BEAR-interactively)
- [Documentation](#Documentation)
- [Distribute BEAR](#Distribute-BEAR)
  * [With other MATLAB users](#With-other-MATLAB-users)
  * [With non MATLAB users](#With-non-MATLAB-users)
- [License](#License)

## Introduction

The Bayesian Estimation, Analysis and Regression toolbox (BEAR) is a comprehensive (Bayesian Panel) VAR toolbox for forecasting and policy analysis.

BEAR is a MATLAB based toolbox which is easy for non-technical users to understand, augment and adapt. In particular, BEAR includes a user-friendly graphical interface which allows the tool to be used by country desk economists.

Furthermore, BEAR is well documented, both within the code as well as including a detailed theoretical and user's guide. BEAR includes state-of-the art applications such as FAVARs, stochastic volatility, time-varying parameters, mixed-frequency, sign and magnitude restrictions, conditional forecasts, Bayesian forecast evaluation measures, Bayesian Panel VAR using different prior distributions (for example hierarchical priors).

BEAR is specifically developed for transparently supplying a tool for state-of-the-art research and is planned to be further developed to always be at the frontier of economic research.

Use of BEAR implies acceptance of the End User [Licence Agreement (EULA)](#License) for the Use of the Software "the Bayesian Estimation, Analysis and Regression (BEAR) toolbox".

[BEAR at ECB](https://www.ecb.europa.eu/pub/research/working-papers/html/bear-toolbox.en.html)

### Structure of the repository
This repository is organized as follows. All BEAR files that need to be installed by the end-users are located inside the `tbx` in four separate directories:
- `app` contains all the files related to the user interface
- `bear` has all the core MATLAB functions and classes
- `replications` contains a set of Excel and settings files to replicate previous results from the literature
- `doc` contains a set of PDFs with some of the BEAR documentation

The rest of the folders contain development files related to the development of BEAR which will not be copied in non-development environments. This folders are structured as follows:
- `tests` contains a set of [MATLAB unit tests](https://uk.mathworks.com/help/matlab/class-based-unit-tests.html) which are automatically run within GitHub actions every time any change is pushed to the master branch.
- `resources` contains the metadata of the MATLAB project `bear.prj`
- `release` contains the definition files that allow the user compiling BEAR into a standalone application
- `images` contains all the images used within the README files of the repository

## Getting started

### Creating a settings object

To create a settings object you can use the function

```
>> s = BEARsettings(<VARtype>, 'ExcelFile','data.xlsx')
```

This will return a settings object with different properties depending on the selected VARtype.

### Running BEAR from the command line

To run BEAR, please use:

```
>> BEARmain(s)
```

where `s` is a BEAR settings object created with the `BEARsettings` function.

### Running BEAR interactively

From MATLAB run the command below to open the main BEAR interface.

```
>> BEARapp
```

## Documentation

For a full BEAR documentation please visit our [doc page](https://github.com/european-central-bank/BEAR-toolbox/tree/master/tbx/doc).