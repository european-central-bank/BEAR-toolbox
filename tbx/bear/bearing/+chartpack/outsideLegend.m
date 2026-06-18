
function legendHandle = outsideLegend(location, varargin)

    MARGIN = 0.01;

    legendHandle = legend(varargin{:});
    set(legendHandle, orientation="horizontal");
    moveLegend(legendHandle, location, MARGIN);

end%


function moveLegend(legendHandle, location, margin)

    parentHandle = get(legendHandle, 'Parent');
    type = get(parentHandle, 'Type');
    while ~strcmpi(type, 'figure')
        parentHandle = get(parentHandle, 'Parent');
        type = get(parentHandle, 'Type');
    end
    set(parentHandle, 'Units', 'Normalized');
    oldPosition = get(legendHandle, 'Position');
    newPosition = oldPosition;
    newPosition(1) = 0.5 - oldPosition(3)/2;
    if strcmpi(location, 'bottom')
        newPosition(2) = margin;
    elseif strcmpi(location, 'top')
        newPosition(2) = (1 - margin) - oldPosition(4);
    end
    set(legendHandle, 'Position', newPosition);

end%

