
%% Report shock contributions to structural model forecast

% Condense the forecast contributions to median
structFcastContMedTbl = tablex.apply(structFcastContTbl, medianFunc);
?HAS_HISTORY?clippedContMedTbl = tablex.clip(contribMedTbl, histStart, histEnd);
?HAS_HISTORY?structFcastContMedTbl = tablex.merge(clippedContMedTbl, structFcastContMedTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "structFcastContMed");

% Save the percentiles of the forecast contributions
% save(outputPath + ".mat", "structFcastContPctTbl");
% tablex.writetimetable(structFcastContPctTbl, outputPath + ".csv");
tablex.writetimetable(structFcastContMedTbl, outputPath + ".xlsx");

% Plot the median forecast shock contributions
figureHandles = chartpack.contributionsMedian( ...
    structFcastContMedTbl, structModel ...
    , "figureTitle", "Shock contributions to structural model forecast (median)" ...
    , "chartSettings", {"vertical", histEnd} ...
);

% Save the figures
chartpack.printFiguresPDF(figureHandles, outputPath);

