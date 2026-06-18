
%% Calculate relative forecast error variance decomposition

% Calculate relative FEVD by normalizing the relolute FEVD by the total variance
% (i.e., sum of FEVD across shocks for each variable and horizon)
relFevdMedTbl = tablex.apply(absFevdMedTbl, @(x) x ./ sum(x, 3));
?PRINT_TABLE?display(relFevdMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "relFevdMed");

% Save the results as percentiles as MAT and/or CSV and/or XLSX files
?SAVE_MAT?save(outputPath + ".mat", "relFevdMedTbl");
?SAVE_CSV?tablex.writetimetable(relFevdMedTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(relFevdMedTbl, outputPath + ".xlsx");

% Plot the relolute FEVD results as percentiles
?DRAW_CHARTS?chartSettings = {
?DRAW_CHARTS?    "timeAxis", "integers", ...
?DRAW_CHARTS?    "referencePeriod", fevdSpan(1), ...
?DRAW_CHARTS?    "axesSettings", {"yLim", [0, 1]} ...
?DRAW_CHARTS?};
?DRAW_CHARTS?figureHandles = chartpack.contributionsMedian( ...
?DRAW_CHARTS?    relFevdMedTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Forecast error variance decomposition (relative, median)" ...
?DRAW_CHARTS?    , "chartSettings", chartSettings ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

