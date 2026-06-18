
%% Report shock contributions to historical paths

?PRINT_TABLE?display(contribPctTbl);
?PRINT_TABLE?display(contribMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "contribMed");

% Save the shock contribution results as median as MAT and/or CSV and/or
% XLSX files
?SAVE_MAT?save(outputPath + ".mat", "contribMedTbl");
?SAVE_CSV?tablex.writetimetable(contribMedTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(contribMedTbl, outputPath + ".xlsx");

% Plot the shock response results as percentiles
?DRAW_CHARTS?figureHandles = chartpack.contributionsMedian( ...
?DRAW_CHARTS?    contribMedTbl, structModel ...
?DRAW_CHARTS?    , "figureTitle", "Shock contributions (median)" ...
?DRAW_CHARTS?);

% Save the figures as a PDF
?DRAW_CHARTS??SAVE_PDF?chartpack.printFiguresPDF(figureHandles, outputPath);

