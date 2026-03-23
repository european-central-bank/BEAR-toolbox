
%% Run unconditional forecast using structural model 

% Run an unconditional forecast using the structural model
[structForecastTbl, structForecastContribsTbl] = structModel.forecast( ...
    ?FORECAST_SPAN? ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , includeInitial=?INCLUDE_INITIAL?...
    , contributions=?CONTRIBUTIONS? ...
);

% Condense the forecast to percentiles
structForecastPercentilesTbl = tablex.apply(structForecastTbl, percentilesFunc);
?PRINT_TABLE?display(structForecastPercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "structForecastPercentiles");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
?SAVE_MAT?save(outputPath + ".mat", "structForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(structForecastPercentilesTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(structForecastPercentilesTbl, outputPath + ".xlsx");

if ~isempty(structForecastContribsTbl)
    % Condense the forecast contributions to percentiles
    structForecastContribsPercentilesTbl = tablex.apply(structForecastContribsTbl, percentilesFunc);

    % Flatten the 3D contributions table to 2D contributions table
    structForecastContribsPercentilesTbl = tablex.flatten(structForecastContribsPercentilesTbl);

    % Define the output path for saving the results
    outputPath = fullfile(outputFolder, "structForecastContribsPercentiles");

    % Save the percentiles of the forecast contributions
    ?SAVE_MAT?save(outputPath + ".mat", "structForecastContribsPercentilesTbl");
    ?SAVE_CSV?tablex.writetimetable(structForecastContribsPercentilesTbl, outputPath + ".csv");
    ?SAVE_XLS?tablex.writetimetable(structForecastContribsPercentilesTbl, outputPath + ".xlsx");
end

% Plot the forecast results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.forecastPercentiles( ...
?DRAW_CHARTS?    structForecastPercentilesTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Structural model forecast (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?);

% Save the figures
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

