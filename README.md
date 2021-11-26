| :exclamation: We just added some major changes into the main functionality of BEAR to improve its usability. To access the previous version of the code use the legacyCode branch |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

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
The Bayesian Estimation, Analysis and Regression toolbox (BEAR) is a comprehensive (Bayesian Panel) VAR toolbox for forecasting and policy analysis. Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software “the Bayesian Estimation, Analysis and Regression (BEAR) toolbox”.
### Structure of the repository
This repository is organized as follows. All BEAR files that need to be installed by the end-users are located inside the `tbx` in four separate directories:
- `app` contains all the files related to the user interface
- `bear` has all the core MATLAB functions and classes
- `replications` contains a set of Excel and settings files to replicate previous results from the literature
- `examples` contains a set of functions to create settings objects for each VAR type
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

To install the toolbox directly from MATLAB, please go to HOME > Add Ons, search for BEAR and install the toolbox (comming soon).

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

### For non-MATLAB users

Under releases, you will find an executable with the compiled application that you can install in any Windows based computer. To run the installer, just download the .EXE file and run it.

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

### Examples

If you want to see an example on how to run BEAR, you can run any of the following files directly:

```
s = bear_settings_BVAR
s = bear_settings_PANEL
s = bear_settings_SV
s = bear_settings_TVP
s = bear_settings_MF
```

change your inputs accordingly and then run `BEARmain(s)`. Alternatively, if you wanted to build your own settings files, you use any of these as a template running for example:

```
copyfile(fullfile(bearroot(), 'examples', 'bear_settings_BVAR.m'), pwd)
edit('bear_settings_BVAR')
```


## Documentation

For a full BEAR documentation please visit our [doc page](https://github.com/european-central-bank/BEAR-toolbox/tree/master/tbx/doc).

## Distribute BEAR

### With other MATLAB users
Any MATLAB user can download the latest version of BEAR from the GitHub repository. However, if you wanted to create your own custom distribution you can package it as a MATLAB toolbox as follows:

1. Open the `tbx.prj` and edit the main fields such as author, version, and description.
2. Either click on package or run:
``` 
projectFile = 'tbx.prj';
matlab.addons.toolbox.packageToolbox(projectFile)
```

### With non-MATLAB users

If you wanted to share BEAR with someone who is not a MATLAB user, there are several routes you can take:
1. You can use MATLAB Compiler to share the APP as a standalone program. For this, please open the **Application Compiler** from the toolstrip:
<br/>

![app toolstrip](/images/AppToolstrip.PNG "Open application compiler")

<br/>

2. Select as **MAIN FILE** the appropriate BEAR app from your set of files. For example, `tbx\app\BEARapp20a`.

<br/>

![Compile app](/images/CompilerScreenshot.PNG "Compiler Screenshot")

<br/>

3. Under **Files required for your application to run** add the following in addition to the automatically detected ones:

+ tbx\bear\\+bear\results.xlsx
+ tbx\replications\data_AAU2009.xlsx
+ tbx\replications\data_BBE2005.xlsx
+ tbx\replications\data_BvV2018.xlsx
+ tbx\replications\data_CH2019.xlsx 
+ tbx\replications\data_WGP2016.xlsx
+ tbx\default_bear_data.xlsx

4. Click on Package.
5. You will get a subfolder with the files that you can use to redistribute the application

### For external language integration

If you wanted to share specific functionality with users of other languages, you can take a look at [Compiler SDK](https://uk.mathworks.com/help/compiler_sdk/index.html). The process is analgous to the previous one but selecting a different target.

## License
Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software “the Bayesian Estimation, Analysis and Regression (BEAR) toolbox”.
[License](/tbx/doc/BEAR%20End%20User%20Licence%20Agreement.pdf)
