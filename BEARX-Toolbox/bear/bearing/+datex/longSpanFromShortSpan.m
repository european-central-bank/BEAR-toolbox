
function longSpan = longSpanFromShortSpan(shortSpan, order)

    arguments
        shortSpan (1, :) datetime
        order (1, 1) double {mustBeInteger, mustBePositive}
    end

    shortStart = shortSpan(1);
    longStart = datex.shift(shortStart, -order);
    longEnd = shortSpan(end);
    longSpan = datex.span(longStart, longEnd);

end%

