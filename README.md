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
- [Getting started](#Getting-started)
  * [Creating a settings object](#Creating-a-settings-object)
  * [Running BEAR from the command line](#Running-BEAR-from-the-command-line)
  * [Running BEAR interactively](#Running-BEAR-interactively)
- [For non-MATLAB users](#For-non-MATLAB-users)
- [License](#License)

## Introduction
The Bayesian Estimation, Analysis and Regression toolbox (BEAR) is a comprehensive (Bayesian Panel) VAR toolbox for forecasting and policy analysis. Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software “the Bayesian Estimation, Analysis and Regression (BEAR) toolbox”.
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

## Installing BEAR
### For users

This section is aimed to those users indending to run BEAR, but not interested in working or ammending the code.

__**From MATLAB**__

To install the toolbox directly from MATLAB, please go to HOME > Add Ons, search for BEAR and install the toolbox.

__**From GitHub**__

Download the latest `bear.mltbx` file that you will find under the Releases section on the right. 
<br/><br/>
![release location in GitHub](/images/releaseLoc.png "release location")
<br/><br/>
Once this file has been downloaded, you can double click it from MATLAB to install the toolbox.
<br/><br/>
![double click on bear.mltbx to install the toolbox](/images/Install.PNG "Manual install from MATLAB")
<br/><br/>

### For developers

If there was a need to modify the BEAR code, it is recommended not to modify the installed version. Instead, the best approach is to clone the repository and open the project. To open the project, you can double click on `bear.prj` in the main folder or rnu the command:

```>> openProject('bear.prj')```

Opening the MATLAB project will shadow the installed version of BEAR as long as the project is open, once the project is shut down, the installed version will again be default version. To check which verison of BEAR is currently running, you can run:

```>> which BEARmain```

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

The recommended version to run BEAR is 21a or above. For older MATLAB versions, use `>> BEARapp20a` or run BEAR from the command line.

## For non-MATLAB users

In the ECB website below, you will find a compiled version of BEAR that does not require a MATLAB license to install.

[BEAR at ECB](https://www.ecb.europa.eu/pub/research/working-papers/html/bear-toolbox.en.html)

## License
[License](/tbx/doc/BEAR%20End%20User%20Licence%20Agreement.pdf)
