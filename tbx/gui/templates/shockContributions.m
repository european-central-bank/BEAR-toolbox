
%% Calculate shock contributions to historical paths

% Calculate the contributions
contribTbl = structModel.calculateContributions( ...
    includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
contribPercentilesTbl = tablex.apply(contribTbl, percentilesFunc);
contribPercentilesTbl = tablex.flatten(contribPercentilesTbl);
?PRINT_TABLE?display(contribPercentilesTbl);

% Condense the results to median and flatten the 3D table to 2D table
contribMedianTbl = tablex.apply(contribTbl, medianFunc);
?PRINT_TABLE?display(contribMedianTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "contribMedian");

% Save the shock contribution results as median as MAT and/or CSV and/or
% XLSX files
?SAVE_MAT?save(outputPath + ".mat", "contribMedianTbl");
?SAVE_CSV?tablex.writetimetable(contribMedianTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(contribMedianTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.contributionsMedian( ...
?DRAW_CHARTS?    contribMedianTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Shock contributions (median)" ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

