
function test_prop()

    userInput = {
        "@SHKRESP(1, 'GDP', 'DEM') > @SHKRESP(1, 'INF', 'DEM')",
        "@SHKEST('2019-2', 'DEM') > 1",
    };

    verifiables = cell(size(userInput));

    for i = 1 : numel(userInput)
        u = userInput{i};
        u = regexprep(u, "@(\w+)\(", "x.extract$1(x, ");
        verifiables{i} = str2func("@(x)" + u);
    end

    x = identifier.custom.State();

    x.addprop("endogenousNames");
    x.endogenousNames = struct(GDP=1, INF=2);

    x.addprop("shockNames");
    x.shockNames = struct(DEM=1, SUP=2);

    x.addprop("historyPeriods");
    x.historyPeriods = struct(P2019_1=1, P2019_2=2);

    for n = ["SHKRESP", "SHKEST"]
        propertyName = "extract" + n;
        x.addprop(propertyName);
        x.(propertyName) = str2func(propertyName);
    end

    for i = 1 : numel(verifiables)
        disp(verifiables{i}(x));
    end

end%
