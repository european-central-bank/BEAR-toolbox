
function finalizeExcelUX(uxFilePath)

    arguments
        uxFilePath (1, 1) string = "BEAR6_UX.xlsx"
    end

    logger = bear6.Logger.INFO;

    logger.info("Reading ExcelUX" + uxFilePath)
    excelUX = bear6.ExcelUX(filePath=uxFilePath);
    logger.info("√ Done")

    config = excelUX.Config;
    metaR = config.createReducedFormMetaObject();
    metaS = config.createStructuralMetaObject(metaR);

    finalizeLongRunDummies(uxFilePath, config, metaR, metaS);
    finalizeInstantZeros(uxFilePath, config, metaR, metaS);
    finalizeSignRestrictions(uxFilePath, config, metaR, metaS);
    finalizeNarrativeShockSigns(uxFilePath, config, metaR, metaS);
    finalizeNarrativeContributions(uxFilePath, config, metaR, metaS);

end%


function finalizeLongRunDummies(uxFilePath, config, metaR, metaS);
    %[
    LONG_RUN_DUMMIES_SHEET = "Long-run dummies";

    namesY = metaR.EndogenousNames;
    numY = numel(namesY);
    add = cell(numY+1, numY+1);
    add(1, 2:end) = cellstr(namesY);
    add(2:end, 1) = cellstr(namesY);

    writecell( ...
        add ...
        , uxFilePath ...
        , sheet=LONG_RUN_DUMMIES_SHEET ...
        , range="A2" ...
    );
    %]
end%


function finalizeInstantZeros(uxFilePath, config, metaR, metaS)
    %[
    INSTANT_ZEROS_SHEET = "Instant shock response zeros";

    namesY = metaR.EndogenousNames;
    namesE = metaS.ShockNames;
    numY = metaR.NumEndogenousNames;
    numE = metaS.NumShocks;
    add = cell(numY+1, numE+1);
    add(1, 2:end) = cellstr(namesE);
    add(2:end, 1) = cellstr(namesY);

    writecell( ...
        add ...
        , uxFilePath ...
        , sheet=INSTANT_ZEROS_SHEET ...
        , range="A2" ...
    );
    %]
end%



function finalizeSignRestrictions(uxFilePath, config, metaR, metaS)
    %[
    SIGN_RESTRICTIONS_SHEET = "Shock response signs";

    namesY = metaR.EndogenousNames;
    namesE = metaS.ShockNames;
    numY = metaR.NumEndogenousNames;
    numE = metaS.NumShocks;
    numT = metaS.IdentificationHorizon;

    add = cell.empty(0, 0);
    divider = cell(1, numE+1);
    for t = 1 : numT
        addT = cell(numY+1, numE+1);
        addT{1, 1} = "t=" + t;
        addT(1, 2:end) = cellstr(namesE);
        addT(2:end, 1) = cellstr(namesY);
        add = [add; addT; divider];
    end

    writecell( ...
        add ...
        , uxFilePath ...
        , sheet=SIGN_RESTRICTIONS_SHEET ...
        , range="A2" ...
    );
    %]
end%



function finalizeNarrativeShockSigns(uxFilePath, config, metaR, metaS)
    %[
    NARRATIVE_SHOCK_SIGNS_SHEET = "Narrative shock signs";

    namesE = metaS.ShockNames;
    estimationSpan = metaR.EstimationSpan;
    numE = numel(namesE);
    numT = numel(estimationSpan);

    add = cell(numT+1, numE+1);
    add(1, 2:end) = cellstr(namesE);
    add(2:end, 1) = cellstr(estimationSpan);

    writecell( ...
        add ...
        , uxFilePath ...
        , sheet=NARRATIVE_SHOCK_SIGNS_SHEET ...
        , range="A2" ...
    );
    %]
end%


function finalizeNarrativeContributions(uxFilePath, config, metaR, metaS)
    %[
    NARRATIVE_CONTRIBUTIONS_SHEET = "Narrative contributions";

    namesY = metaR.EndogenousNames;
    namesE = metaS.ShockNames;
    numY = metaR.NumEndogenousNames;
    numE = metaS.NumShocks;
    estimationSpan = metaR.EstimationSpan;
    numT = numel(estimationSpan);

    add = cell.empty(0, 0);
    divider = cell(1, numE+1);
    for t = 1 : numT
        addT = cell(numY+1, numE+1);
        addT{1, 1} = "t=" + string(estimationSpan(t));
        addT(1, 2:end) = cellstr(namesE);
        addT(2:end, 1) = cellstr(namesY);
        add = [add; addT; divider];
    end

    writecell( ...
        add ...
        , uxFilePath ...
        , sheet=NARRATIVE_CONTRIBUTIONS_SHEET ...
        , range="A2" ...
    );
    %]
end%

