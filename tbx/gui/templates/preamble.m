%% Automatically generated BEARX Toolbox script
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it further to your
% needs.
%
% Generated ?TIMESTAMP?
%


%% Clear workspace

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

% Import the correct module
import ?MODULE?.*


%% Define percentile function for summarizing the results

% User choice of percentiles
percentiles = ?PERCENTILES?;

% Create a percentiles function used to condense and report some results
percentilesFunc = @(x) prctile(x, percentiles, 2);

% Create a median function used to condense and report some results
medianFunc = @(x) median(x, 2);

% Create a legend for the percentiles
percentilesLegend = compose("%d%%", percentiles);


%% Prepare the output folder

outputFolder = fullfile(".", ?OUTPUT_FOLDER?);
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end


%% Prepare an empty array of dummies

dummyObjects = {};

