
function varargout = plotPercentiles(varargin)

    [varargout{1:nargout}] = tablex.plot(varargin{:}, "plotSettingsFunc", {@setColor_});

end%


function setColor_(axesHandle, plotHandles)
    %[
    colorOrder = get(axesHandle, "colorOrder");
    numColors = size(colorOrder, 1);
    numLines = numel(plotHandles);
    if numLines/2 ~= round(numLines/2)
        coreLineIndex = ceil(numLines/2);
        numBands = (numLines - 1)/2;
    else
        coreLineIndex = [round(numLines/2), round(numLines/2)+1];
        numBands = (numLines - 2)/2;
    end

    set( ...
        plotHandles(coreLineIndex) ...
        , color=colorOrder(1, :) ...
        , lineStyle="-" ...
    )

    for i = 1 : numBands
        bandLineIndex1 = coreLineIndex(1) - i;
        bandLineIndex2 = coreLineIndex(end) + i;
        colorIndex = mod(i-1, numColors) + 2;
        bandColor = colorOrder(colorIndex, :);
        set( ...
            plotHandles([bandLineIndex1, bandLineIndex2]) ...
            , color=bandColor ...
            , lineStyle=":" ...
        )
    end
    %]
end%

