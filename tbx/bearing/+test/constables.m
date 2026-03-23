
close all
clear
clear classes
rehash path


endogenous = ["DOM_GDP", "DOM_CPI", "STN"]
shocks = ["e1", "e2", "e3"]


instantZero = constable.new( ...
    rowNames=endogenous, ...
    columnNames=shocks ...
);


instantZero{"DOM_GDP", "e2"} = 0;
instantZero{"DOM_CPI", "e3"} = 0;

disp("Instant zeros")
disp(instantZero)


irfSignRestrict = constable.new( ...
    rowNames=endogenous, ...
    columnNames=shocks, ...
    periods=1:4, ...
    initValue=NaN ...
);


irfSignRestrict{"DOM_GDP", "e1"}(1:3) = -1;

disp("IRF signs")
disp(irfSignRestrict)


