%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated 28-May-2026 17:11:38
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Import the correct module
import base.*


%% Define percentile function for summarizing the results

% User choice of percentiles
percentiles = [10 50 90];

% Create a percentiles function used to condense and report some results
percentilesFunc = @(x) prctile(x, percentiles, 2);

% Create a median function used to condense and report some results
medianFunc = @(x) median(x, 2);

% Create a legend for the percentiles
percentilesLegend = compose("%d%%", percentiles);


%% Prepare the output folder

outputFolder = fullfile(".", "output");
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end


%% Prepare an empty array of dummies

dummyObjects = {};


%% Prepare an empty array for shock contributions

contribTbl = [];


%% Prepare plot settings

linePlotSettings = {
    "lineWidth", 1.5 ...
};


%% Prepare meta information 

% Create a meta information object
meta = Meta( ...
    EndogenousNames=["GDP_GROWTH", "INFLATION", "SHORT_RATE"] ...
    , ExogenousNames="OIL" ...
    , ShockNames=["DEM", "SUP", "MP"] ...
    , Order=2 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1990-Q3", "2017-Q4") ...
    , IdentificationHorizon=20 ...
);


%% Load input data table 

% Load the input data table
inputTbl = tablex.fromFile("./syntheticVAR.csv");
display(inputTbl);


%% Create DataHolder object 

dataHolderObject = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimatorObject = estimator.IndNormalWishart( ...
    meta ...
    , Sigma="ar" ...
    , Burnin=0 ...
    , StabilityThreshold=1 ...
    , MaxNumUnstableAttempts=1000 ...
    , Exogenous=false ...
    , BlockExogenous=false ...
    , Autoregression=0.8 ...
    , Lambda1=0.1 ...
    , Lambda2=0.5 ...
    , Lambda3=1 ...
    , Lambda4=100 ...
    , Lambda5=0.001 ...
);


%% Create reduced-form model 

% Assemble a reduced-form model from the components
redModel = ReducedForm( ...
    Meta=meta ...
    , DataHolder=dataHolderObject ...
    , Estimator=estimatorObject ...
    , Dummies=dummyObjects ...
);

display(redModel);


%% Initialize and presample the reduced-form model 

redModel.initialize();
info = redModel.presample(1000);
display(info);


%% Run unconditional forecast using reduced-form model

% Define forecast periods
fcastSpan = datex.span("2018-Q1", "2019-Q4");
fcastStart = fcastSpan(1);
histEnd = datex.shift(fcastStart, -1);
histStart = datex.shift(fcastStart, -8);

% Run an unconditional forecast using the reduced-form model
redFcastTbl = redModel.forecast( ...
    fcastSpan ...
    , stochasticResiduals=true ...
    , includeInitial=false ...
);

% Condense the forecast to percentiles
redFcastPctTbl = tablex.apply(redFcastTbl, percentilesFunc);
clippedInputTbl = tablex.clip(inputTbl, histStart, histEnd);
redFcastPctTbl = tablex.merge(clippedInputTbl, redFcastPctTbl);
display(redFcastPctTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "redFcastPct");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
save(outputPath + ".mat", "redFcastPctTbl");
tablex.writetimetable(redFcastPctTbl, outputPath + ".csv");
tablex.writetimetable(redFcastPctTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
figureHandles = chartpack.forecastPercentiles( ...
    redFcastPctTbl, redModel ...
    , "figureTitle", "Reduced-form model forecast (percentiles)" ...
    , "figureLegend", percentilesLegend ...
    , "chartSettings", {"plotSettings", linePlotSettings, "vertical", histEnd} ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Run conditional forecast 

% Define forecast periods
fcastSpan = datex.span("2018-Q1", "2019-Q4");
fcastStart = fcastSpan(1);
histEnd = datex.shift(fcastStart, -1);
histStart = datex.shift(fcastStart, -8);

% Read table with custom conditioning data
inputPath = fullfile("tables", "ConditioningData.xlsx");
conditioningData = tablex.readConditioningData( ...
    inputPath, ...
    timeColumn="Conditioning data" ...
);
display(conditioningData);

% No conditioning plan used, all shocks are taken into account
conditioningPlan = [];


% Run a conditional forecast
[condFcastTbl, condFcastContTbl] = structModel.conditionalForecast( ...
    fcastSpan ...
    , conditions=conditioningData ...
    , plan=conditioningPlan ...
    , exogenousFrom="inputData" ...
    , contributions=false ...
    , includeInitial=false ...
);

% Condense the results to percentiles
condFcastPctTbl = tablex.apply(condFcastTbl, percentilesFunc);
clippedInputTbl = tablex.clip(inputTbl, histStart, histEnd);
condFcastPctTbl = tablex.merge(clippedInputTbl, condFcastPctTbl);
display(condFcastPctTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "condFcastPct");

% Save the conditional forecast results as percentiles as MAT and/or CSV and/or
% XLSX files
%===save(outputPath + ".mat", "condFcastPctTbl");
%===tablex.writetimetable(condFcastPctTbl, outputPath + ".csv");
tablex.writetimetable(condFcastPctTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
figureHandles = chartpack.conditionalForecastPercentiles( ...
    condFcastPctTbl, structModel ...
    , "figureTitle", "Conditional forecast (percentiles)" ...
    , "figureLegend", percentilesLegend ...
    , "chartSettings", {"plotSettings", linePlotSettings, "vertical", histEnd} ...
);

% Save the figures
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Calculate forecast error variance decomposition

% Calculate FEVD over shock response horizon
[absFevdTbl, fevdSpan] = structModel.calculateFEVD(includeInitial=false);

% Condense the results to median and flatten the 3D table to 2D table
absFevdMedTbl = tablex.apply(absFevdTbl, medianFunc);
display(absFevdMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "absFevdMed");

% Save the results as percentiles as MAT and/or CSV and/or XLSX files
save(outputPath + ".mat", "absFevdMedTbl");
tablex.writetimetable(absFevdMedTbl, outputPath + ".csv");
tablex.writetimetable(absFevdMedTbl, outputPath + ".xlsx");

% Plot the absolute FEVD results as percentiles
chartSettings = {
    "timeAxis", "integers", ...
    "referencePeriod", fevdSpan(1) ...
};
figureHandles = chartpack.contributionsMedian( ...
    absFevdMedTbl, structModel ...
    , "figureTitle", "Forecast error variance decomposition (median)" ...
    , "chartSettings", chartSettings ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Calculate relative forecast error variance decomposition

% Calculate relative FEVD by normalizing the relolute FEVD by the total variance
% (i.e., sum of FEVD across shocks for each variable and horizon)
relFevdMedTbl = tablex.apply(absFevdMedTbl, @(x) x ./ sum(x, 3));
display(relFevdMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "relFevdMed");

% Save the results as percentiles as MAT and/or CSV and/or XLSX files
save(outputPath + ".mat", "relFevdMedTbl");
tablex.writetimetable(relFevdMedTbl, outputPath + ".csv");
tablex.writetimetable(relFevdMedTbl, outputPath + ".xlsx");

% Plot the relolute FEVD results as percentiles
chartSettings = {
    "timeAxis", "integers", ...
    "referencePeriod", fevdSpan(1), ...
    "axesSettings", {"yLim", [0, 1]} ...
};
figureHandles = chartpack.contributionsMedian( ...
    relFevdMedTbl, structModel ...
    , "figureTitle", "Forecast error variance decomposition (relative, median)" ...
    , "chartSettings", chartSettings ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Tasks completed

fprintf("\n\nAll selected tasks have been completed.\n");
fprintf("Check the output folder <a href=""matlab: ls %s"">%s</a> for the results.\n\n", outputFolder, outputFolder);

gui.returnFromCommandWindow();

