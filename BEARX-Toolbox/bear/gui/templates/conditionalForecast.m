
%% Run conditional forecast 

% Define forecast periods
fcastSpan = ?FORECAST_SPAN?;
fcastStart = fcastSpan(1);
histEnd = datex.shift(fcastStart, -1);
?HAS_HISTORY?histStart = datex.shift(fcastStart, -?NUM_HISTORY?);

% Read table with custom conditioning data
inputPath = fullfile("tables", "ConditioningData.xlsx");
conditioningData = tablex.readConditioningData( ...
    inputPath, ...
    timeColumn="Conditioning data" ...
);
?PRINT_TABLE?display(conditioningData);

?PLAN?

% Run a conditional forecast
[condFcastTbl, condFcastContTbl] = structModel.conditionalForecast( ...
    fcastSpan ...
    , conditions=conditioningData ...
    , plan=conditioningPlan ...
    , exogenousFrom="?EXOGENOUS_FROM?" ...
    , contributions=?CONTRIBUTIONS? ...
    , includeInitial=false ...
);

% Condense the results to percentiles
condFcastPctTbl = tablex.apply(condFcastTbl, percentilesFunc);
?HAS_HISTORY?clippedInputTbl = tablex.clip(inputTbl, histStart, histEnd);
?HAS_HISTORY?condFcastPctTbl = tablex.merge(clippedInputTbl, condFcastPctTbl);
?PRINT_TABLE?display(condFcastPctTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "condFcastPct");

% Save the conditional forecast results as percentiles as MAT and/or CSV and/or
% XLSX files
?SAVE_MAT?save(outputPath + ".mat", "condFcastPctTbl");
?SAVE_CSV?tablex.writetimetable(condFcastPctTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(condFcastPctTbl, outputPath + ".xlsx");

% Plot the forecast results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.conditionalForecastPercentiles( ...
?DRAW_CHARTS?    condFcastPctTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Conditional forecast (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?    , "chartSettings", {"plotSettings", linePlotSettings, "vertical", histEnd} ...
?DRAW_CHARTS?);

% Save the figures
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

