
function d = diff(period1, period2)

    fh1 = datex.Backend.getFrequencyHandlerFromDatetime(period1);
    fh2 = datex.Backend.getFrequencyHandlerFromDatetime(period2);
    if string(class(fh1)) ~= string(class(fh2))
        error("Periods must have the same time frequency");
    end
    serial1 = fh1.serialFromDatetime(period1);
    serial2 = fh2.serialFromDatetime(period2);
    d = serial1 - serial2;

end%

