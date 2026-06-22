
function mid = middleBefore(date)
    dateBefore = datex.shift(date, -1);
    duration = date - dateBefore;
    mid = dateBefore + duration / 2;
end%

