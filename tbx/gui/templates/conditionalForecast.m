
%% Run conditional forecast 

% Read table with custom conditioning data
inputPath__ = fullfile("tables", "ConditioningData.xlsx");
conditioningData = tablex.readConditioningData( ...
    inputPath__, ...
    timeColumn="Conditioning data" ...
);
?PRINT_TABLE?display(conditioningData);

?PLAN?

% Run a conditional forecast
[condForecastTbl, condForecastContribsTbl] = structModel.conditionalForecast( ...
    ?FORECAST_SPAN? ...
    , conditions=conditioningData ...
    , plan=conditioningPlan ...
    , exogenousFrom="?EXOGENOUS_FROM?" ...
    , contributions=?CONTRIBUTIONS? ...
    , includeInitial=?INCLUDE_INITIAL?...
);

% Condense the results to percentiles
condForecastPercentilesTbl = tablex.apply(condForecastTbl, percentilesFunc);
?PRINT_TABLE?display(condForecastPercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "condForecastPercentiles");

% Save the conditional forecast results as percentiles as MAT and/or CSV and/or
% XLSX files
?SAVE_MAT?save(outputPath + ".mat", "condForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(condForecastPercentilesTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(condForecastPercentilesTbl, outputPath + ".xlsx");

if ~isempty(condForecastContribsTbl)
    % Condense the results to percentiles
    condForecastContribsPercentilesTbl = tablex.apply(condForecastContribsTbl, percentilesFunc);

    % Flatten the 3D contributions table to 2D contributions table
    condForecastContribsPercentilesTbl = tablex.flatten(condForecastContribsPercentilesTbl);

    % Define the output path for saving the results
    outputPath = fullfile(outputFolder, "condForecastContribsPercentiles");

    % Save the results
    ?SAVE_MAT?save(outputPath + ".mat", "condForecastContribsPercentilesTbl");
    ?SAVE_CSV?tablex.writetimetable(condForecastContribsPercentilesTbl, outputPath + ".csv");
    ?SAVE_XLS?tablex.writetimetable(condForecastContribsPercentilesTbl, outputPath + ".xlsx");
end

% Plot the forecast results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.conditionalForecastPercentiles( ...
?DRAW_CHARTS?    condForecastPercentilesTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Conditional forecast (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?);

% Save the figures
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

