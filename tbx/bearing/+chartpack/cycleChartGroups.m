
function figureHandles = cycleChartGroups(chartFunc, tt, chartGroups, varargin)

    figureHandles = cell.empty(1,0);
    for i = 1 : numel(chartGroups) 
        if isempty(chartGroups{i})
            continue
        end
        currentFigureHandles = chartpack.framework( ...
            chartFunc, tt, chartGroups{i} ...
            , "numFiguresSoFar", numel(figureHandles) ...
            , varargin{:} ...
        );
        figureHandles = [figureHandles, currentFigureHandles];
    end
    figure(figureHandles{1});

end%

