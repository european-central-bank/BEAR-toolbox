
%% Calculate forecast error variance decomposition (FEVD)

% Calculate FEVD over shock response horizon
[fevdTbl, fevdSpan] = structModel.calculateFEVD( ...
    includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
fevdPercentilesTbl = tablex.apply(fevdTbl, percentilesFunc);
fevdPercentilesTbl = tablex.flatten(fevdPercentilesTbl);
?PRINT_TABLE?display(fevdPercentilesTbl);

% Condense the results to median and flatten the 3D table to 2D table
fevdMedianTbl = tablex.apply(fevdTbl, medianFunc);
?PRINT_TABLE?display(fevdMedianTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "fevdPercentiles");

% Save the results as percentiles as MAT and/or CSV and/or XLSX files
?SAVE_MAT?save(outputPath + ".mat", "fevdPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(fevdPercentilesTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(fevdPercentilesTbl, outputPath + ".xlsx");

% Plot the FEVD results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.contributionsMedian( ...
?DRAW_CHARTS?    fevdMedianTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Forecast error variance decomposition (median)" ...
?DRAW_CHARTS?    , "chartSettings", {"timeAxis", "integers", "referencePeriod", fevdSpan(1)} ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

