

clear

span = datex.span("2020-Q1", "2022-Q4");
numPeriods = numel(span);

variableNames = ["DOM_GDP", "DOM_CPI", "STN"];
numVariables = numel(variableNames);

init = repmat({cell(numPeriods, 1)}, 1, numVariables);


% Simulation plan for all shocks

t1 = timetable( ...
    init{:}, ...
    rowTimes=span, ...
    variableNames=variableNames ...
);

t1{datex("2021-Q2"), "DOM_CPI"} = {true};
t1{datex("2022-Q3"), "DOM_GDP"} = {true};

t1



% Simulation plan for selected shocks

t2 = timetable( ...
    init{:}, ...
    rowTimes=span, ...
    variableNames=variableNames ...
);

t2{datex("2021-Q2"), "DOM_CPI"} = {["DEM", "SUP"]};
t2{datex("2022-Q3"), "DOM_GDP"} = {["POL"]};

t2


list = ["POL", "POL", "DEM", "SUP", "POL"]; %modelS.Meta.ShockNames

dict = textual.createDictionary(list);

list2 = arrayfun(@(x) dict.(x), list);

