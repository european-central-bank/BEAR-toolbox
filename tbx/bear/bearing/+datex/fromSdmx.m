

function dt = fromSdmx(inputStrings)

    inputStrings = string(inputStrings);

    fh = datex.Backend.getFrequencyHandlerFromSdmx(inputStrings(1));

    if isequaln(fh, NaN)
        error("Cannot recognize time frequency from input string: %s", inputStrings(1));
    end

    dt = datetime.empty(0, 1);
    dt.Format = fh.Format;
    for i = 1 : numel(inputStrings)
        dt(i, 1) = fh.datetimeFromSdmx(inputStrings(i));
    end

end%
