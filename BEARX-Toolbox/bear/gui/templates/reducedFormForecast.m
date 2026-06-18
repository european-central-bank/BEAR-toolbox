
%% Run unconditional forecast using reduced-form model

% Define forecast periods
fcastSpan = ?FORECAST_SPAN?;
fcastStart = fcastSpan(1);
histEnd = datex.shift(fcastStart, -1);
?HAS_HISTORY?histStart = datex.shift(fcastStart, -?NUM_HISTORY?);

% Run an unconditional forecast using the reduced-form model
redFcastTbl = redModel.forecast( ...
    fcastSpan ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , includeInitial=false ...
);

% Condense the forecast to percentiles
redFcastPctTbl = tablex.apply(redFcastTbl, percentilesFunc);
?HAS_HISTORY?clippedInputTbl = tablex.clip(inputTbl, histStart, histEnd);
?HAS_HISTORY?redFcastPctTbl = tablex.merge(clippedInputTbl, redFcastPctTbl);
?PRINT_TABLE?display(redFcastPctTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "redFcastPct");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
?SAVE_MAT?save(outputPath + ".mat", "redFcastPctTbl");
?SAVE_CSV?tablex.writetimetable(redFcastPctTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(redFcastPctTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.forecastPercentiles( ...
?DRAW_CHARTS?    redFcastPctTbl, redModel ...
?DRAW_CHARTS?    , "figureTitle", "Reduced-form model forecast (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?    , "chartSettings", {"plotSettings", linePlotSettings, "vertical", histEnd} ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

