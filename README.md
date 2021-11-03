# The BEAR toolbox
## Introduction
The Bayesian Estimation, Analysis and Regression toolbox (BEAR) is a comprehensive (Bayesian Panel) VAR toolbox for forecasting and policy analysis. Use of BEAR implies acceptance of the End User Licence Agreement (EULA) for the Use of the Software “the Bayesian Estimation, Analysis and Regression (BEAR) toolbox”.
## Installing BEAR
### For users

__**From MATLAB**__

To install the toolbox directly from MATLAB, please go to HOME > Add Ons, search for BEAR and install the toolbox.

__**From GitHub**__

Download the latest `bear.mltbx` file that you will find under the Releases section on the right. Double click to this file from MATLAB to install the toolbox.

### For developers
Clone the repository into your local machine. 
Double click on `bear.prj` in the main folder to open the project and start working with the latest BEAR release. Having the project open will overload any installed version of BEAR.

## Getting started

### Settings object

To create a settings object you can use the function

```
>> s = BEARsettings(<VARtype>, 'ExcelFile','data.xlsx')
```

This will return a settings object with different properties depending on the selected VARtype.

### Running BEAR

To run BEAR, please use:

```
>> BEARmain(s)
```

where `s` is a BEAR settings object created with the `BEARsettings` function.

### Interactive BEAR

From MATLAB run the command below to open the main BEAR interface.

```
>> BEARapp
```

The recommended version to run BEAR is 21a or above. For older MATLAB versions, use `>> BEARapp20a` or run BEAR from the command line.

## For non-MATLAB users

In the ECB website below, you will find a compiled version of BEAR that does not require a MATLAB license to install.

[BEAR at ECB](https://www.ecb.europa.eu/pub/research/working-papers/html/bear-toolbox.en.html)

## License
[License](/tbx/bear/BEAR End User Licence Agreement.pdf)
