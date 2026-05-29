%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated 16-Nov-2025 21:37:02
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

% Import the correct module
import mixed.*


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
    HighFrequencyNames=["CPILFESL_PCH", "TB3MS"] ...
    , LowFrequencyNames=["GDPC1_PCH", "GPDIC1_PCH"] ...
    , ExogenousNames=[] ...
    , ShockNames=[] ...
    , Order=6 ...
    , Intercept=true ...
    , EstimationSpan=datex.span("1981-07", "2024-12") ...
    , IdentificationHorizon=4 ...
);


%% Load input data table 

% Load the input data table
inputTbl = tablex.fromFile("./mixedMonthly.csv");
display(inputTbl);


%% Add low-frequency data

% Find out the base frequency of the model
baseFrequency = tablex.frequency(inputTbl);

% Load the input table with low-frequency data
lowFrequencyInputTbl = tablex.fromFile("./mixedQuarterly.csv");
display(lowFrequencyInputTbl);

% Convert the low-frequency data to base-frequency data
lowFrequencyInputTbl = tablex.upsample( ...
    lowFrequencyInputTbl, ...
    baseFrequency, ...
    method="last" ...
);
display(lowFrequencyInputTbl);

% Add the low-frequency data to the main input table. Use stratege="error" to
% throw an error if there are any duplicate names.
inputTbl = tablex.merge( ...
    inputTbl, ...
    lowFrequencyInputTbl, ...
    strategy="error" ...
);
display(inputTbl);


%% Create DataHolder object 

dataHolderObject = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimatorObject = estimator.MixedFrequency( ...
    meta ...
    , MixedLambda1=0.1 ...
    , MixedLambda2=3.4 ...
    , MixedLambda3=1 ...
    , MixedLambda4=3.4 ...
    , MixedLambda5=14.763158 ...
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
info = redModel.presample(100);
display(info);


%% Create Cholesky identification object 

ident = identifier.Cholesky( ...
    Order="" ...
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
info = structModel.presample(100);
display(info);

% save(fullfile(outputFolder, "structuralModel.mat"), "structModel");


%% Run unconditional forecast using reduced-form model

% Run an unconditional forecast using the structural model
redForecastTbl = redModel.forecast( ...
    datex.span("2025-01", "2025-12") ...
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

