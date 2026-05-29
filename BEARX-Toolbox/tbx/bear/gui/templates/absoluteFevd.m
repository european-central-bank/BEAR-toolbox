
%% Calculate forecast error variance decomposition

% Calculate FEVD over shock response horizon
[absFevdTbl, fevdSpan] = structModel.calculateFEVD(includeInitial=false);

% Condense the results to median and flatten the 3D table to 2D table
absFevdMedTbl = tablex.apply(absFevdTbl, medianFunc);
?PRINT_TABLE?display(absFevdMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "absFevdMed");

% Save the results as percentiles as MAT and/or CSV and/or XLSX files
?SAVE_MAT?save(outputPath + ".mat", "absFevdMedTbl");
?SAVE_CSV?tablex.writetimetable(absFevdMedTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(absFevdMedTbl, outputPath + ".xlsx");

% Plot the absolute FEVD results as percentiles
?DRAW_CHARTS?chartSettings = {
?DRAW_CHARTS?    "timeAxis", "integers", ...
?DRAW_CHARTS?    "referencePeriod", fevdSpan(1) ...
?DRAW_CHARTS?};
?DRAW_CHARTS?figureHandles = chartpack.contributionsMedian( ...
?DRAW_CHARTS?    absFevdMedTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Forecast error variance decomposition (median)" ...
?DRAW_CHARTS?    , "chartSettings", chartSettings ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

