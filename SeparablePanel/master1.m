%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated 12-Nov-2025 10:47:27
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

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


%% Prepare meta information 

% Create a meta information object
meta = Meta( ...
    EndogenousConcepts=["YER", "HICSA", "STN"] ...
    , Units=["US", "EA", "UK"] ...
    , ExogenousNames="Oil" ...
    , ShockConcepts=["DEM", "SUP", "POL"] ...
    , Order=3 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1975-Q1", "2014-Q4") ...
    , IdentificationHorizon=4 ...
);


%% Load input data table 

% Load the input data table
inputTbl = tablex.fromFile("/Users/myself/Documents/ogr-external-projects/ecb-bear/BEARX-GUI-Examples/SeparablePanel/inputData.csv");
display(inputTbl);


%% Create DataHolder object 

dataHolderObject = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimatorObject = estimator.MeanOLSPanel( ...
    meta ...
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


%% Create InstantZeros identification object 

ident = identifier.InstantZeros( ...
    FileName="tables/InstantZeros.xlsx" ...
    , RandomGenerator="randn" ...
    , FactorizationFunc="chol" ...
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

% save(fullfile(outputFolder, "structuralModel.mat"), "structModel");


%% Run unconditional forecast using reduced-form model

% Run an unconditional forecast using the structural model
redForecastTbl = redModel.forecast( ...
    datex.span("2015-Q1", "2016-Q4") ...
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
% figureHandles = chartpack.forecastPercentiles( ...
%     redForecastPercentilesTbl, redModel ...
%     , "figureTitle", "Reduced-form model forecast (percentiles)" ...
%     , "figureLegend", percentilesLegend ...
% );

% Save the figures as a PDF
% % chartpack.printFiguresPDF(figureHandles, outputPath);


%% Simulate shock responses

% Simulate the responses to shocks over the shock response horizon
responseTbl = structModel.simulateResponses( ...
    includeInitial=true ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
responsePercentilesTbl = tablex.apply(responseTbl, percentilesFunc);
responsePercentilesTbl = tablex.flatten(responsePercentilesTbl);
display(responsePercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "responsePercentiles");

% Save the shock response results as percentiles as MAT and/or CSV and/or XLSX
% files
% save(outputPath + ".mat", "responsePercentilesTbl");
% tablex.writetimetable(responsePercentilesTbl, outputPath + ".csv");
tablex.writetimetable(responsePercentilesTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
figureHandles = chartpack.responsePercentiles( ...
    responsePercentilesTbl, structModel ...
    , "figureTitle", "Shock response (percentiles)" ...
    , "figureLegend", percentilesLegend ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);


%% Calculate shock contributions to historical paths

% Calculate the contributions
contribTbl = structModel.calculateContributions( ...
    includeInitial=false ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
contribPercentilesTbl = tablex.apply(contribTbl, percentilesFunc);
contribPercentilesTbl = tablex.flatten(contribPercentilesTbl);
display(contribPercentilesTbl);

% Condense the results to median and flatten the 3D table to 2D table
contribMedianTbl = tablex.apply(contribTbl, medianFunc);
display(contribMedianTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "contribMedian");

% Save the shock contribution results as median as MAT and/or CSV and/or
% XLSX files
% save(outputPath + ".mat", "contribMedianTbl");
% tablex.writetimetable(contribMedianTbl, outputPath + ".csv");
tablex.writetimetable(contribMedianTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
figureHandles = chartpack.contributionsMedian( ...
    contribMedianTbl, structModel ...
    , "figureTitle", "Shock contributions (median)" ...
);

% Save the figures as a PDF
chartpack.printFiguresPDF(figureHandles, outputPath);

%% Tasks completed

fprintf("\n\nAll selected tasks have been completed.\n");
fprintf("Check the output folder <a href=""matlab: ls %s"">%s</a> for the results.\n\n", outputFolder, outputFolder);


