%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated 28-May-2026 11:33:28
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

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
    EndogenousNames=["GDP", "CPI", "STN"] ...
    , ExogenousNames="Oil" ...
    , ShockNames=["DEM", "SUP", "POL"] ...
    , Order=2 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1975-Q1", "2014-Q4") ...
    , IdentificationHorizon=4 ...
);


%% Load input data table 

% Load the input data table
inputTbl = tablex.fromFile("./exampleDataX.csv");
display(inputTbl);


%% Create DataHolder object 

dataHolderObject = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimatorObject = estimator.NormalWishart( ...
    meta ...
    , Sigma="ar" ...
    , Burnin=0 ...
    , StabilityThreshold=NaN ...
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


%% Create Cholesky identification object 

ident = identifier.Cholesky( ...
    Order=[] ...
);

display(ident);


%% Create a structural model 

structModel = Structural( ...
    reducedForm=redModel ...
    , identifier=ident ...
);
display(structModel);


%% Initialize and presample the structural model 

structModel.initialize();
info = structModel.presample(1000);
display(info);

%===save(fullfile(outputFolder, "structuralModel.mat"), "structModel");


%% Run unconditional forecast using reduced-form model

% Define forecast periods
fcastSpan = datex.span("2015-Q1", "2016-Q4");
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
%===save(outputPath + ".mat", "redFcastPctTbl");
%===tablex.writetimetable(redFcastPctTbl, outputPath + ".csv");
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


%% Calculate shock contributions to historical paths

% Calculate the contributions
contribTbl = structModel.calculateContributions();

% Condense the results to percentiles and flatten the 3D table to 2D table
contribPctTbl = tablex.apply(contribTbl, percentilesFunc);
contribPctTbl = tablex.flatten(contribPctTbl);

% Condense the results to median and flatten the 3D table to 2D table
contribMedTbl = tablex.apply(contribTbl, medianFunc);


%% Report shock contributions to historical paths

display(contribPctTbl);
display(contribMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "contribMed");

% Save the shock contribution results as median as MAT and/or CSV and/or
% XLSX files
%===save(outputPath + ".mat", "contribMedTbl");
%===tablex.writetimetable(contribMedTbl, outputPath + ".csv");
tablex.writetimetable(contribMedTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
figureHandles = chartpack.contributionsMedian( ...
    contribMedTbl, structModel ...
    , "figureTitle", "Shock contributions (median)" ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Run unconditional forecast using structural model 

% Define forecast periods
fcastSpan = datex.span("2015-Q1", "2016-Q4");
fcastStart = fcastSpan(1);
histEnd = datex.shift(fcastStart, -1);
histStart = datex.shift(fcastStart, -8);

% Run an unconditional forecast using the structural model
[structFcastTbl, structFcastContTbl] = structModel.forecast( ...
    fcastSpan ...
    , stochasticResiduals=true ...
    , contributions=true ...
    , precontributions=contribTbl ...
    , includeInitial=false ...
);

% Condense the forecast to percentiles
structFcastPctTbl = tablex.apply(structFcastTbl, percentilesFunc);
clippedInputTbl = tablex.clip(inputTbl, histStart, histEnd);
structFcastPctTbl = tablex.merge(clippedInputTbl, structFcastPctTbl);
display(structFcastPctTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "structFcastPct");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
%===save(outputPath + ".mat", "structFcastPctTbl");
%===tablex.writetimetable(structFcastPctTbl, outputPath + ".csv");
tablex.writetimetable(structFcastPctTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
figureHandles = chartpack.forecastPercentiles( ...
    structFcastPctTbl, structModel ...
    , "figureTitle", "Structural model forecast (percentiles)" ...
    , "figureLegend", percentilesLegend ...
    , "chartSettings", {"plotSettings", linePlotSettings, "vertical", histEnd} ...
);

% Save the figures
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Report shock contributions to structural model forecast

% Condense the forecast contributions to median
structFcastContMedTbl = tablex.apply(structFcastContTbl, medianFunc);
clippedContMedTbl = tablex.clip(contribMedTbl, histStart, histEnd);
structFcastContMedTbl = tablex.merge(clippedContMedTbl, structFcastContMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "structFcastContMed");

% Save the percentiles of the forecast contributions
% save(outputPath + ".mat", "structFcastContPctTbl");
% tablex.writetimetable(structFcastContPctTbl, outputPath + ".csv");
tablex.writetimetable(structFcastContMedTbl, outputPath + ".xlsx");

% Plot the median forecast shock contributions
figureHandles = chartpack.contributionsMedian( ...
    structFcastContMedTbl, structModel ...
    , "figureTitle", "Shock contributions to structural model forecast (median)" ...
    , "chartSettings", {"vertical", histEnd} ...
);

% Save the figures
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Run conditional forecast 

% Define forecast periods
fcastSpan = datex.span("2015-Q1", "2016-Q4");
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

% Read table with custom conditioning plan
inputPath = fullfile("tables", "ConditioningPlan.xlsx");
conditioningPlan = tablex.readConditioningPlan( ...
    inputPath, ...
    timeColumn="Conditioning plan" ...
);
display(conditioningPlan);


% Run a conditional forecast
[condFcastTbl, condFcastContTbl] = structModel.conditionalForecast( ...
    fcastSpan ...
    , conditions=conditioningData ...
    , plan=conditioningPlan ...
    , exogenousFrom="inputData" ...
    , contributions=true ...
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


%% Simulate shock responses

% Simulate the responses to shocks over the shock response horizon
[responseTbl, responseSpan] = structModel.simulateResponses(includeInitial=true);

% Condense the results to percentiles and flatten the 3D table to 2D table
responsePercentilesTbl = tablex.apply(responseTbl, percentilesFunc);
responsePercentilesTbl = tablex.flatten(responsePercentilesTbl);
display(responsePercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "responsePercentiles");

% Save the shock response results as percentiles as MAT and/or CSV and/or XLSX
% files
%===save(outputPath + ".mat", "responsePercentilesTbl");
%===tablex.writetimetable(responsePercentilesTbl, outputPath + ".csv");
tablex.writetimetable(responsePercentilesTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
figureHandles = chartpack.responsePercentiles( ...
    responsePercentilesTbl, structModel ...
    , "figureTitle", "Shock response (percentiles)" ...
    , "figureLegend", percentilesLegend ...
    , "chartSettings", {"timeAxis", "integers", "referencePeriod", responseSpan(1), "plotSettings", linePlotSettings} ...
);

% Save the figures as a PDF
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
%===save(outputPath + ".mat", "absFevdMedTbl");
%===tablex.writetimetable(absFevdMedTbl, outputPath + ".csv");
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
%===save(outputPath + ".mat", "relFevdMedTbl");
%===tablex.writetimetable(relFevdMedTbl, outputPath + ".csv");
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

