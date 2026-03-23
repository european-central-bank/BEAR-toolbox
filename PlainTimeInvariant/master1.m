%% Automatically generated BEAR Toolbox script 
%
% This script was generated based on the user input from the BEAR Toolbox
% Graphical User Interface. Feel free to edit and adapt it furthere to your
% needs.
%
% Generated 10-Oct-2025 11:19:45
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


%% Define convenience functions for future use 

% User choice of percentiles
percentiles = [10 50 90];

% Aggregation functions used to summarize distributions
prctilesFunc = @(x) prctile(x, percentiles, 2);
medianFunc = @(x) median(x, 2);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];


%% Prepare output folder 

outputFolder = fullfile(".", "output");
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end


%% Set up print functions

printInfo = @display; % @(x) [];
printTable = @display; % @(x) [];
printObject = @display; % @(x) [];


%% Prepare meta information 

% Create a meta information object
meta = Meta( ...
    EndogenousNames=["GDP", "CPI", "STN"] ...
    , ExogenousNames="Oil" ...
    , ShockNames=["DEM", "SUP", "POL"] ...
    , Order=2 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1977-Q1", "2014-Q4") ...
    , IdentificationHorizon=4 ...
);


%% Prepare input data holder 

% Load the input data table
inputTbl = tablex.fromCsv("/Users/myself/Documents/ogr-external-projects/ecb-bear/BEAR-toolbox/tbx/gui_poc/exampleDataX.csv");
printTable(inputTbl);

% Create a data holder object
dataHolder = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimator = estimator.NormalWishart( ...
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
    , DataHolder=dataHolder ...
    , Estimator=estimator ...
);
printObject(redModel);


%% Initialize and presample the reduced-form model 

redModel.initialize();
info = redModel.presample(1000);
printInfo(info);

uncForecastTbl = redModel.forecast( ...
    datex.span("2015-Q1", "2016-Q4") ...
    , stochasticResiduals=true ...
    , includeInitial=true ...
);

residualTbl = redModel.estimateResiduals(progress=false);


%% Create an identification object 

identifier = identifier.Cholesky( ...
    Order=string.empty(1, 0) ...
);


%% Create a structural model 

structModel = Structural( ...
    reducedForm=redModel ...
    , identifier=identifier ...
);
printObject(structModel);


%% Initialize and presample the structural model 

structModel.initialize();
info = structModel.presample(1000);
printInfo(info);

% save(fullfile(outputFolder, "structuralModel.mat"), "structModel");


%% Run unconditional forecast 

uncForecastTbl = structModel.forecast( ...
    datex.span("2015-Q1", "2016-Q4") ...
    , stochasticResiduals=true ...
    , includeInitial=true ...
);

uncForecastPercentilesTbl = tablex.apply(uncForecastTbl, prctilesFunc);

% save(fullfile(outputFolder, "uncForecastPercentiles.mat"), "uncForecastPercentilesTbl");
tablex.writetimetable(uncForecastPercentilesTbl, fullfile(outputFolder, "uncForecastPercentiles.csv"));
tablex.writetimetable(uncForecastPercentilesTbl, fullfile(outputFolder, "uncForecastPercentiles.xls"));

