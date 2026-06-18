
function [fcastTbl, contribsTbl] = conditionalForecast(this, fcastSpan, options)

    arguments
        this
        fcastSpan (1, :) datetime

        options.Conditions (:, :) timetable
        options.Plan = []
        options.IncludeInitial (1, 1) logical = true

        options.Contributions (1, 1) logical = false
        options.Precontributions = []
    end

    VARIANT_DIM = 3;
    CONTRIB_DIM = 3;

    meta = this.Meta;
    numY = meta.NumEndogenousNames;
    order = meta.Order;
    numL = numY * order;
    shortFcastSpan = datex.ensureSpan(fcastSpan);
    fcastStart = shortFcastSpan(1);
    longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
    fcastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
    fcastHorizon = numel(shortFcastSpan);
    initSpan = datex.initSpanFromShortSpan(shortFcastSpan, meta.Order);
    initYXZ = this.getSomeYXZ(initSpan);
    initY = initYXZ{1};
    fcastX = tablex.retrieveData(options.Conditions, meta.ExogenousNames, shortFcastSpan);

    cfconds = conditional.createConditionsCF(meta, options.Plan, options.Conditions, shortFcastSpan);
    cfshocks = conditional.createShocksCF(meta, options.Plan, shortFcastSpan);
    cfblocks = conditional.createBlocksCF(cfconds, cfshocks);
    numShockConcepts = meta.NumShockConcepts;

    legacyOptions = struct();
    legacyOptions.hasIntercept = meta.HasIntercept;
    legacyOptions.order = meta.Order;
    legacyOptions.cfconds = [];
    legacyOptions.cfblocks = [];
    legacyOptions.cfshocks = [];

    numPresampled = this.NumPresampled;
    progressMessage = sprintf("Conditional forecast [%g]", numPresampled);

    numUnits = meta.getNumSeparableUnits();
    if numUnits > 1
        if ~isempty(cfconds)
            cfconds = reshape(cfconds, size(cfconds, 1), [], numUnits);
        end
        if ~isempty(cfshocks)
            cfshocks = reshape(cfshocks, size(cfshocks, 1), [], numUnits);
        end
        if ~isempty(cfblocks)
            cfblocks = reshape(cfblocks, size(cfblocks, 1), [], numUnits);
        end
    end
    fcastY = cell(1, numPresampled);
    fcastE = cell(1, numPresampled);

    if options.Contributions
        [contributor, contribs, precontribs] ...
            = this.prepareForContributions(shortFcastSpan, options.Precontributions);
    end

    pbar = progress.Bar(progressMessage, numPresampled*numUnits);
    for i = 1 : numPresampled
        sample = this.Presampled{i};
        draw = this.ConditionalDrawer(sample, fcastStartIndex, fcastHorizon);
        for j = 1 : numUnits
            if ~isempty(cfconds)
                legacyOptions.cfconds = cfconds(:, :, j);
            end
            if ~isempty(cfshocks)
                legacyOptions.cfshocks = cfshocks(:, :, j);
                for k = 1 : numel(legacyOptions.cfshocks)
                    legacyOptions.cfshocks{k} = legacyOptions.cfshocks{k} - (j-1)*numShockConcepts;
                end
            end
            if ~isempty(cfblocks)
                legacyOptions.cfblocks = cfblocks(:, :, j);
            end
            unitInitY = initY(:, :, j);
            unitD = sample.D(:, :, j);
            unitBeta = meta.extractUnitFromCells(draw.beta, j, dim=2);
            [unitY, unitE] = conditional.forecast(transpose(unitD), [unitBeta{:}], unitInitY, fcastX, fcastHorizon, legacyOptions);
            fcastY{i} = [fcastY{i}, unitY];
            fcastE{i} = [fcastE{i}, unitE];

            if options.Contributions
                unitA = cell(1, fcastHorizon);
                unitC = cell(1, fcastHorizon);
                for k = 1 : fcastHorizon
                    unitB = reshape(unitBeta{k}, [], numY);
                    unitA{k} = unitB(1:numL, :);
                    unitC{k} = unitB(numL+1:end, :);
                end
                unitContribs = contributor(unitA, unitC, unitD, unitE, fcastX, unitInitY, precontribs(:, :, :, i));
                contribs{i} = [contribs{i}, unitContribs];
            end

            pbar.increment();
        end
    end

    fcastY = cat(VARIANT_DIM, fcastY{:});
    fcastE = cat(VARIANT_DIM, fcastE{:});
    outNames = [meta.EndogenousNames, meta.ShockNames];
    outData = [fcastY, fcastE];
    outSpan = shortFcastSpan;
    if options.IncludeInitial
        outSpan = longFcastSpan;
        initData = [repmat(initY(:, :), 1, 1, numPresampled), zeros(order, numY, numPresampled)];
        outData = [initData; outData];
    end

    fcastTbl = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=VARIANT_DIM);

    contribsTbl = [];
    if options.Contributions
        contribsTbl = this.tabulateContributions(contribs, shortFcastSpan);
    end

end%

