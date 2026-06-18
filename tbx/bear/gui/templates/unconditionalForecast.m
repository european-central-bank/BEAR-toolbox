
%% Run unconditional forecast 

uncForecastTbl = structModel.forecast( ...
    ?FORECAST_SPAN? ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , includeInitial=?INCLUDE_INITIAL? ...
);

uncForecastPercentilesTbl = tablex.apply(uncForecastTbl, prctilesFunc);

?SAVE_MAT?save(fullfile(outputFolder, "uncForecastPercentiles.mat"), "uncForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(uncForecastPercentilesTbl, fullfile(outputFolder, "uncForecastPercentiles.csv"));
?SAVE_XLS?tablex.writetimetable(uncForecastPercentilesTbl, fullfile(outputFolder, "uncForecastPercentiles.xls"));

