
function dt = shift(dt, by)

    if isequal(by, 0)
        return
    end

    if isempty(dt)
        return
    end

    fh = datex.Backend.getFrequencyHandlerFromDatetime(dt(1));
    serial = fh.serialFromDatetime(dt);
    serial = serial + by;
    dt = fh.datetimeFromSerial(serial);

end%

