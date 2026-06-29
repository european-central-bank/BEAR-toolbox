
%% Run unconditional forecast using structural model 

% Define forecast periods
fcastSpan = ?FORECAST_SPAN?;
fcastStart = fcastSpan(1);
histEnd = datex.shift(fcastStart, -1);
?HAS_HISTORY?histStart = datex.shift(fcastStart, -?NUM_HISTORY?);

% Run an unconditional forecast using the structural model
[structFcastTbl, structFcastContTbl] = structModel.forecast( ...
    fcastSpan ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , contributions=?CONTRIBUTIONS? ...
    , precontributions=contribTbl ...
    , includeInitial=false ...
);

% Condense the forecast to percentiles
structFcastPctTbl = tablex.apply(structFcastTbl, percentilesFunc);
?HAS_HISTORY?clippedInputTbl = tablex.clip(inputTbl, histStart, histEnd);
?HAS_HISTORY?structFcastPctTbl = tablex.merge(clippedInputTbl, structFcastPctTbl);
?PRINT_TABLE?display(structFcastPctTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "structFcastPct");

% Save the forecast results as percentiles as MAT and/or CSV and/or
% and XLS files
?SAVE_MAT?save(outputPath + ".mat", "structFcastPctTbl");
?SAVE_CSV?tablex.writetimetable(structFcastPctTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(structFcastPctTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.forecastPercentiles( ...
?DRAW_CHARTS?    structFcastPctTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Structural model forecast (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?    , "chartSettings", {"plotSettings", linePlotSettings, "vertical", histEnd} ...
?DRAW_CHARTS?);

% Save the figures
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

