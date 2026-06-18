
function spans = getObservationPeriods(tt, appendTo)

    arguments
        tt
        appendTo struct = struct()
    end

    spans = appendTo;
    names = tablex.names(tt);
    allSpan = tablex.span(tt);
    for n = names
        data = tt.(n);
        spans.(n) = getObservationPeriods_(allSpan, data);
    end

end%


function out = getObservationPeriods_(allSpan, data)
    isNonNan = any(~isnan(data(:, :)), 2);
    out = allSpan(isNonNan);
end%

