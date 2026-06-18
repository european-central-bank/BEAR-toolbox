
function code = codeDummies()

    VARIABLE_NAMES = struct( ...
        Minnesota="minnesotaDummies", ...
        SumCoeff="sumCoeffDummies", ...
        InitialObs="initialObsDummies", ...
        LongRun="longRunDummies" ...
    );

    code = string.empty(0, 1);

    dummies = gui.getCurrentDummies();

    if isempty(dummies)
        return
    end

    template = scripter.readTemplate("dummies");

    for n = dummies 
        path = {"dummies", n};
        settings = gui.readFormsFile(path);

        place = struct();
        place.TYPE = n;
        place.VARIABLE_NAME = VARIABLE_NAMES.(n);
        place.SETTINGS = scripter.printFormAsSettings(settings);

        code = [code; scripter.replaceInCode(template, place)];
    end

end%

