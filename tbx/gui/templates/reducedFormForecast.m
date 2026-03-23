
%% Run unconditional forecast using reduced-form model

% Run an unconditional forecast using the structural model
redForecastTbl = redModel.forecast( ...
    ?FORECAST_SPAN? ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the forecast to percentiles
redForecastPercentilesTbl = tablex.apply(redForecastTbl, percentilesFunc);
?PRINT_TABLE?display(redForecastPercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "redForecastPercentiles");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
?SAVE_MAT?save(outputPath + ".mat", "redForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(redForecastPercentilesTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(redForecastPercentilesTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.forecastPercentiles( ...
?DRAW_CHARTS?    redForecastPercentilesTbl, redModel ...
?DRAW_CHARTS?    , "figureTitle", "Reduced-form model forecast (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

