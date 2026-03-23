
function [outputTbl, contribTbl] = forecast(this, fcastSpan, options)

    arguments
        this
        fcastSpan (1, :) datetime
        options.StochasticResiduals (1, 1) logical = true
        options.IncludeInitial (1, 1) logical = true
        options.Contributions (1, 1) logical = false
        options.Precontributions = []
    end

    meta = this.Meta;
    order = meta.Order;
    fcastSpan = datex.ensureSpan(fcastSpan);

    [forecaster, tabulator] = this.ReducedForm.prepareForecaster( ...
        fcastSpan, ...
        stochasticResiduals=options.StochasticResiduals, ...
        includeInitial=options.IncludeInitial ...
    );

    numPresampled = this.NumPresampled;
    numSeparableUnits = meta.NumSeparableUnits;

    shortY = cell(1, numPresampled);
    shortX = cell(1, numPresampled);
    shortU = cell(1, numPresampled);
    initY = cell(1, numPresampled);

    if options.Contributions
        [contributor, precontribs] = this.prepareContributor(fcastSpan, options.Precontributions);
        contribs = cell(1, numPresampled);
    end

    EXTRACT_DIM = 3;
    for i = 1 : numPresampled
        sample = this.Presampled{i};
        [shortY{i}, shortU{i}, initY{i}, shortX{i}, draw] = forecaster(sample);

        if options.Contributions
            unflatShortU = system.unflattenSeparableUnits(shortU{i}, numSeparableUnits);
            unflatInitY = system.unflattenSeparableUnits(initY{i}, numSeparableUnits);
            for unit = 1 : numSeparableUnits
                unitD = sample.D(:, :, unit);
                unitShortU = unflatShortU(:, :, unit);
                unitInitY = unflatInitY(:, :, unit);
                unitA = system.extractUnitFromCellArray(draw.A, unit, EXTRACT_DIM);
                unitC = system.extractUnitFromCellArray(draw.C, unit, EXTRACT_DIM);
                %
                unitContribs = contributor(unitA, unitC, unitD, unitShortU, shortX{i}, unitInitY, precontribs(:, :, :, i));
                contribs{i} = [contribs{i}, unitContribs];
            end
        end
    end

    outputTbl = tabulator(shortY, shortU, initY, shortX);

    contribTbl = [];
    if options.Contributions
        contribTbl = this.tabulateContributions(contribs, fcastSpan);
    end

end%

