

startPeriod = datex.q(2020,1);
endPeriod = datex.q(2020,4);
periods = datex.span(startPeriod, endPeriod);

ct = constable.new(["A", "B"], ["X", "Y", "Z"], periods);

restrictDates = [datex.q(2020,2), datex.q(2020,3)];
inx = constable.periodPositions(ct, restrictDates);

ct{"A", "X"}(inx) = 0;
ct{"B", "Z"}(inx) = -1;

disp(ct)
disp(constable.periods(ct))

