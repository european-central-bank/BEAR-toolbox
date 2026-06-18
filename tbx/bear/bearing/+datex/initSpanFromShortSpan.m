
function initSpan = initSpanFromShortSpan(shortSpan, order)

    arguments
        shortSpan (1, :) datetime
        order (1, 1) double {mustBeInteger, mustBePositive}
    end

    shortStart = shortSpan(1);
    initStart = datex.shift(shortStart, -order);
    initEnd = datex.shift(shortStart, -1);
    initSpan = datex.span(initStart, initEnd);

end%

