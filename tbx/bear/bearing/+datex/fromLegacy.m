

function dt = fromLegacy(inputStrings)

    inputStrings = string(inputStrings);
    fh = datex.Backend.getFrequencyHandlerFromLegacy(inputStrings(1));
    dt = datetime.empty(0, 1);
    dt.Format = fh.Format;
    for i = 1 : numel(inputStrings)
        dt(i, 1) = fh.datetimeFromLegacy(inputStrings(i));
    end

end%
