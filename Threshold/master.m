%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated 02-Mar-2026 11:44:57
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

% Import the correct module
import threshold.*


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


%% Prepare meta information 

% Create a meta information object
meta = Meta( ...
    EndogenousNames=["dl_y", "dl_cpi", "ir_tb", "stock_index"] ...
    , ThresholdName="stock_index" ...
    , ExogenousNames=[] ...
    , ShockNames=[] ...
    , Order=4 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1949-Q1", "2016-Q4") ...
    , IdentificationHorizon=20 ...
);


%% Load input data table 

% Load the input data table
inputTbl = tablex.fromFile("./threshold_data.csv");
display(inputTbl);


%% Create DataHolder object 

dataHolderObject = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimatorObject = estimator.Threshold( ...
    meta ...
    , VarThreshold=10 ...
    , MaxDelay=4 ...
    , ThresholdPropStd=0.031622776601684 ...
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


%% Run unconditional forecast using reduced-form model

% Run an unconditional forecast using the structural model
redForecastTbl = redModel.forecast( ...
    datex.span("2012-Q1", "2016-Q4") ...
    , stochasticResiduals=true ...
    , includeInitial=true ...
);

% Condense the forecast to percentiles
redForecastPercentilesTbl = tablex.apply(redForecastTbl, percentilesFunc);
display(redForecastPercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "redForecastPercentiles");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
% save(outputPath + ".mat", "redForecastPercentilesTbl");
% tablex.writetimetable(redForecastPercentilesTbl, outputPath + ".csv");
tablex.writetimetable(redForecastPercentilesTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
figureHandles = chartpack.forecastPercentiles( ...
    redForecastPercentilesTbl, redModel ...
    , "figureTitle", "Reduced-form model forecast (percentiles)" ...
    , "figureLegend", percentilesLegend ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Tasks completed

fprintf("\n\nAll selected tasks have been completed.\n");
fprintf("Check the output folder <a href=""matlab: ls %s"">%s</a> for the results.\n\n", outputFolder, outputFolder);

gui.returnFromCommandWindow();

