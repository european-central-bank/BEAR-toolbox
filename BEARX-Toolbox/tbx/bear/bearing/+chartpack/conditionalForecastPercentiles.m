
function figureHandles = conditionalForecastPercentiles(tt, model, varargin)

    meta = model.getMeta();
    chartGroups = meta.getConditionalForecastChartGroups();

    maxNumNames = max(cellfun(@numel, chartGroups));
    tiling = chartpack.getAutoTiling(maxNumNames);

    chartFunc = @tablex.plotPercentiles;

    figureHandles = chartpack.cycleChartGroups( ...
        chartFunc, tt, chartGroups ...
        , "tiling", tiling ...
        , varargin{:} ...
    );

end%

