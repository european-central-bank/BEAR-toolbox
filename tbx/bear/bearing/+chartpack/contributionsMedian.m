
function figureHandles = contributionsMedian(tt, model, varargin)

    meta = model.getMeta();
    chartGroups = meta.getContributionsChartGroups();

    maxNumNames = max(cellfun(@numel, chartGroups));
    tiling = chartpack.getAutoTiling(maxNumNames);

    chartFunc = @tablex.bar;

    higherDims = tablex.getHigherDims(tt);
    figureLegend = higherDims{1};

    figureHandles = chartpack.cycleChartGroups( ...
        chartFunc, tt, chartGroups ...
        , "tiling", tiling ...
        , "figureLegend", figureLegend ...
        , varargin{:} ...
    );

end%

