
function span = ensureSpan(userSpan)

    arguments
        userSpan (1, :) datetime
    end

    spanStart = userSpan(1);
    spanEnd = userSpan(end);
    span = datex.span(spanStart, spanEnd);

end%

