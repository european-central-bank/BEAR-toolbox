%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated 20-Mar-2026 13:09:54
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Import the correct module
import separable.*


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
    EndogenousConcepts=["YER", "HICSA", "STN"] ...
    , Units=["US", "EA", "UK"] ...
    , ExogenousNames="Oil" ...
    , ShockConcepts=["DEM", "SUP", "POL"] ...
    , Order=2 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1975-Q1", "2014-Q4") ...
    , IdentificationHorizon=4 ...
);


%% Load input data table 

% Load the input data table
inputTbl = tablex.fromFile("./inputData.csv");
display(inputTbl);


%% Create DataHolder object 

dataHolderObject = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimatorObject = estimator.HierarchicalPanel( ...
    meta ...
    , S0=0.001 ...
    , V0=0.001 ...
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


%% Tasks completed

fprintf("\n\nAll selected tasks have been completed.\n");
fprintf("Check the output folder <a href=""matlab: ls %s"">%s</a> for the results.\n\n", outputFolder, outputFolder);

gui.returnFromCommandWindow();

