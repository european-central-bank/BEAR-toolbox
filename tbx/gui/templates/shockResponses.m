
%% Simulate shock responses

% Simulate the responses to shocks over the shock response horizon
[responseTbl, responseSpan] = structModel.simulateResponses( ...
    includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
responsePercentilesTbl = tablex.apply(responseTbl, percentilesFunc);
responsePercentilesTbl = tablex.flatten(responsePercentilesTbl);
?PRINT_TABLE?display(responsePercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "responsePercentiles");

% Save the shock response results as percentiles as MAT and/or CSV and/or XLSX
% files
?SAVE_MAT?save(outputPath + ".mat", "responsePercentilesTbl");
?SAVE_CSV?tablex.writetimetable(responsePercentilesTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(responsePercentilesTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.responsePercentiles( ...
?DRAW_CHARTS?    responsePercentilesTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Shock response (percentiles)" ...
?DRAW_CHARTS?    , "figureLegend", percentilesLegend ...
?DRAW_CHARTS?    , "chartSettings", {"timeAxis", "integers", "referencePeriod", responseSpan(1)} ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

