
function [plotHandles, axesHandle] = drawChart(plotFunc, tt, names, options)

    arguments
        plotFunc function_handle
        tt timetable
        names (1, :) string
        %
        options.Periods = Inf
        options.AxesHandle = []
        options.Variant = ':'
        options.Dims (1, :) cell = cell.empty(1, 0)
        options.PlotSettings (1, :) cell = {}
        options.AxesSettings (1, :) cell = {}
        options.PlotSettingsFunc (1, :) cell = {}
        options.Title = ""
        %
        options.TimeAxis (1, 1) string = "periods"
        options.ReferencePeriod (1, 1) = NaN
        %
        options.BarPadding (1, 1) logical = false
        options.Vertical = []
    end

    if isstring(options.Variant)
        options.Variant = char(options.Variant);
    end

    periods = options.Periods;
    if isequal(periods, Inf)
        periods = tablex.span(tt);
    end

    barPadding = 0;
    if options.TimeAxis == "periods"
        timeAxis = periods;
        xLim = [timeAxis(1), timeAxis(end)];
        if options.BarPadding
            t1 = timeAxis(1);
            t0 = datex.shift(t1, -1);
            barPadding = (t1 - t0) / 2;
        end
    else
        % timeAxis = 0 : (numel(periods)-1);
        if isequaln(options.ReferencePeriod, NaN)
            error("ReferencePeriod must be specified when TimeAxis is 'integers'.");
        end
        timeAxis = 1 + datex.diff(periods, options.ReferencePeriod);
        xLim = [timeAxis(1), timeAxis(end)];
        if options.BarPadding
            barPadding = 0.5;
        end
    end

    timeAxisStart = timeAxis(1);
    if barPadding > 0
        xLim = xLim + [-barPadding, barPadding];
    end

    if ~isempty(options.AxesHandle)
        axesHandle = options.AxesHandle;
    else
        axesHandle = gca();
    end

    axesSettings = options.AxesSettings;
    axesSettings = [ ...
        {"xlim", xLim} ...
        , axesSettings ...
    ];

    dataCell = tablex.retrieveDataAsCellArray( ...
        tt, names, periods, ...
        variant=options.Variant, ...
        dims=options.Dims ...
    );

    for i = 1 : numel(dataCell)
        dataCell{i} = dataCell{i}(:,:);
    end

    plotHandles = plotFunc(axesHandle, timeAxis, [dataCell{:}]);
    drawVertical_(axesHandle, options.Vertical, timeAxisStart, barPadding);

    if ~isempty(axesSettings)
        set(axesHandle, axesSettings{:});
    end

    chartTitle = options.Title;
    if chartTitle == ""
        chartTitle = join(names, " | ");
    end
    title(axesHandle, chartTitle, interpreter="none");

    if ~isempty(options.PlotSettings)
        set(plotHandles, options.PlotSettings{:});
    end

    if ~isempty(options.PlotSettingsFunc)
        for i = 1 : numel(options.PlotSettingsFunc)
            func = options.PlotSettingsFunc{i};
            func(axesHandle, plotHandles);
        end
    end

end%


function drawVertical_(axesHandle, vertical, timeAxisStart, barPadding)
    %[
    if isempty(vertical)
        return
    end
    %
    if vertical <= timeAxisStart
        return
    end
    if barPadding > 0
        vertical = vertical + barPadding;
    end
    %
    xline( ...
        axesHandle, vertical ...
        , "color", 0.7 * [1, 1, 1] ...
        , "lineWidth", 3 ...
    );
    %]
end%

