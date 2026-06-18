
function tbx = shift(tbx, by)

    periods = tbx.Time;
    periods = datex.shift(periods, by);
    tbx.Time = periods;

end%

