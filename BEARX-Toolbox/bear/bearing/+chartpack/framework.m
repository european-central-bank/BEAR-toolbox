
function figureHandles = framework(chartFunc, tt, names, options)

    arguments
        chartFunc function_handle
        tt timetable
        names (1, :) string
        %
        options.Tiling = []
        options.MaxNumTilesOnPage = 25
        options.TileSpacing = "compact"
        options.Padding = "loose"
        options.FigureTitle (1, 1) string = ""
        options.FigureLegend (1, :) string = string.empty(1, 0)
        options.FigureCount (1, 1) double = 1
        options.ChartSettings (1, :) cell = cell.empty(1, 0)
        options.InsertEmpty (1, 1) logical = true
        options.NumFiguresSoFar (1, 1) double = 0
    end

    if isempty(names)
        error("No variable names specified for the chartpack.");
    end

    options.ChartSettings = [ ...
        {"periods", tablex.span(tt)} ...
        , options.ChartSettings ...
    ];

    numNames = numel(names);
    tiling = options.Tiling;
    if isempty(tiling)
        tiling = chartpack.getAutoTiling(numNames, options.MaxNumTilesOnPage);
    end
    numTiles = prod(tiling);
    tiledlayoutArgs = { ...
        tiling(1), tiling(2) ...
        , "tileSpacing", options.TileSpacing ...
        , "padding", options.Padding ...
    };

    function figureHandle = createNewFigure_()
        figureHandle = figure();
        tiledlayout(tiledlayoutArgs{:});
    end%

    figureHandles = cell.empty(1, 0);
    axesHandles = cell.empty(1, 0);
    figureHandles{end+1} = createNewFigure_();
    axesHandles{end+1} = cell.empty(1, 0);
    figureCount = options.FigureCount;

    for name = names
        try
            currentAxesHandle = nexttile();
        catch
            figureHandles{end+1} = createNewFigure_(); %#ok<AGROW>
            axesHandles{end+1} = cell.empty(1, 0); %#ok<AGROW>
            figureCount = figureCount + 1;
            currentAxesHandle = nexttile();
        end
        chartFunc(tt, name, options.ChartSettings{:}, "axesHandle", currentAxesHandle);
        axesHandles{figureCount}{end+1} = currentAxesHandle;
    end

    if ~isempty(options.FigureLegend)
        for i = 1 : numel(axesHandles)
            if isempty(axesHandles{i})
                continue
            end
            chartpack.outsideLegend( ...
                "bottom", ...
                axesHandles{i}{1}, ...
                options.FigureLegend ...
            );
        end
    end

    if options.InsertEmpty && numel(axesHandles{end}) < numTiles
        for i = numel(axesHandles{end}) + 1 : numTiles
            chartpack.createEmptyTile();
        end
    end

    if options.FigureTitle ~= ""
        addFigureTitles(figureHandles, options.FigureTitle, options.NumFiguresSoFar);
    end

end%


function addFigureTitles(figureHandles, figureTitle, numFiguresSoFar)
    %[
    numFigures = numel(figureHandles);
    for i = 1 : numFigures
        if figureTitle ~= ""
            currentFigureTitle = figureTitle + sprintf(" [%g]", numFiguresSoFar + i);
            set(figureHandles{i}, name=currentFigureTitle);
            chartpack.figureTitle(figureHandles{i}, currentFigureTitle);
        end
    end
    %]
end%


function addFigureLegends(figureHandles, axesHandles, figureLegend, legendLocation)
    %[
    numFigures = numel(figureHandles);
    for i = 1 : numFigures
        lastAxesHandle = axesHandles{i}{end};
        chartpack.figureLegend(lastAxesHandle, legendLocation, figureLegend);
    end
    %]
end%

