
<a name="T_3795D8B6"></a>
# <span style="color:rgb(213,80,0)">BEAR</span>
<a name="beginToc"></a>
## Table of Contents
[Quick Guide](#H_5194ADD6)
 
[OLS VAR](#H_C9D87C44)
 
&emsp;[Bayesian VAR](#H_8F830DE7)
 
&emsp;[PANEL VAR](#H_79E2BAEE)
 
&emsp;[Stochastic Volatility](#H_0C663C91)
 
&emsp;[Time Varying Panel](#H_F7A1563A)
 
&emsp;[Mixed Frequency](#H_413C373A)
 
[Applications](#H_3B88EB60)
 
&emsp;[Impulse Response Functions](#H_231A6857)
 
&emsp;[Unconditional Forecasts](#H_8DFCADBE)
 
&emsp;[Forecast Error Variance](#H_811CB45A)
 
&emsp;[Historical Decompositions](#H_4C47CFC6)
 
&emsp;[Conditional Forecasts](#H_EE37E1B9)
 
[Replications](#H_B3AD755D)
 
<a name="endToc"></a>
<a name="H_5194ADD6"></a>
# Quick Guide

First of all, you should probably understand basic [OLS VAR models](#H_C9D87C44)


BEAR has two sets of inputs.

-  A number of timeseries and tables that you normally enter in an Excel file 
-  A nubmer of inputs that you pass in as a struct. 

You can create such a group of settings and run BEAR as follows

```matlab
s = BEARsettings('BVAR', data = "default_bear_data.xlsx")
BEARmain(s)
```
<a name="H_8BB0D5E4"></a>
# **Common Settings**

Here we discuss how to run a generic BEAR model and the basic "generic" settings. The equivalent to the Blue Box in the BEAR app. For example:

```matlab
s = BEARsettings("BVAR", data = "default_bear_data.xlsx")
```

Optional inputs:

-  frequency  % data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated) 
-  startdate    % sample start date; must be a string consistent with the date formats of the toolbox 
-  enddate     % sample end date; must be a string consistent with the date formats of the toolbox 
-  varendo     % endogenous variables; must be a single string, with variable names separated by a space 
-  varexo       % exogenous variables, if any; must be a single string, with variable names separated by a space 
-  lags           % number of lags 
-  const         % inclusion of a constant (1=yes, 0=no) 
-  data 
-  results          % save the results in the excel file (true/false) 
-  results_path % path where there results file is stored 
-  results_sub  % name of the results file 
-  plot               % plot the results (true/false) 
-  Debug           % save error 
-  workspace    % save the workspace as a .mat file (true/false) 
<a name="H_47BE6EC6"></a>
# **VAR Type**

This is the most important setting for BEAR. It decides which type of model you are running. 


This settings cannot be changed, becuase a lot of properties are dependent on it, so once you create a specific settings object, you either stick with it or recreate.

<a name="H_C9D87C44"></a>
# OLS VAR

Brief explanation

```matlab
s = BEARsettings("OLS", data = "default_bear_data.xlsx")
BEARmain(s)
```

[Detailed Explanation](./OLS.mlx)

<a name="H_8F830DE7"></a>
## Bayesian VAR

Brief explanation

```matlab
s = BEARsettings("BVAR", data = "default_bear_data.xlsx")
BEARmain(s)
```
<a name="H_79E2BAEE"></a>
## PANEL VAR

Brief explanation

```matlab
s = BEARsettings("PANEL", data = "default_bear_data.xlsx")
BEARmain(s)
```
<a name="H_0C663C91"></a>
## Stochastic Volatility

Brief explanation

```matlab
s = BEARsettings("SV", data = "default_bear_data.xlsx")
BEARmain(s)
```
<a name="H_F7A1563A"></a>
## Time Varying Panel

Brief explanation

```matlab
s = BEARsettings("TVP", data = "default_bear_data.xlsx")
BEARmain(s)
```
<a name="H_413C373A"></a>
## Mixed Frequency

Brief explanation

```matlab
s = BEARsettings("MFVAR", data = "default_bear_data.xlsx")
BEARmain(s)
```
<a name="H_3B88EB60"></a>
# Applications

This is where the applications tab is explained

<a name="H_231A6857"></a>
## Impulse Response Functions

Basic description and quick example

```matlab
s = BEARsettings('BVAR', IRF = 1, IRFt = 'Cholesky', IRFperiods = 20)
BEARmain(s)
```

[More here](./IRF.mlx)

<a name="H_8DFCADBE"></a>
## Unconditional Forecasts
<a name="H_811CB45A"></a>
## Forecast Error Variance

Basic description and quick example

```matlab
s = BEARsettings('BVAR', F = 1, Fstartdate = '2014q1', Fenddate = '2016q4', Fendsmpl = true)
BEARmain(s)
```

[More here](./Forecasts.mlx)

<a name="H_4C47CFC6"></a>
## Historical Decompositions
<a name="H_EE37E1B9"></a>
## Conditional Forecasts
<a name="H_B3AD755D"></a>
# Replications
