
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
    numUnits = meta.getNumSeparableUnits();
    shortY = cell(1, numPresampled);
    shortX = cell(1, numPresampled);
    shortU = cell(1, numPresampled);
    initY = cell(1, numPresampled);

    if options.Contributions
        [contributor, contribs, precontribs] = this.prepareForContributions(fcastSpan, options.Precontributions);
    end

    for i = 1 : numPresampled
        sample = this.Presampled{i};
        [shortY{i}, shortU{i}, initY{i}, shortX{i}, draw] = forecaster(sample);
        shortE = system.shocksFromResiduals(shortU{i}, sample.D);
        if options.Contributions
            contribs{i} = contributor(draw.A, draw.C, sample.D, shortE, shortX{i}, initY{i}, precontribs(:, :, :, i));
            %    % iterate over units
            %    unflatShortU = meta.reshapeCrossUnitData(shortU{i});
            %    unflatInitY = meta.reshapeCrossUnitData(initY{i});
            %    for j = 1 : numUnits
            %        unitD = sample.D(:, :, j);
            %        unitU = unflatShortU(:, :, j);
            %        unitInitY = unflatInitY(:, :, j);
            %        unitA = meta.extractUnitFromCells(draw.A, j, dim=3);
            %        unitC = meta.extractUnitFromCells(draw.C, j, dim=3);
            %        shortE = shocksFromResiduals_(unitU, unitD);
            %        unitContribs = contributor(unitA, unitC, unitD, shortE, shortX{i}, unitInitY, precontribs(:, :, :, i));
            %        contribs{i} = [contribs{i}, unitContribs];
            %    end
        end
    end

    outputTbl = tabulator(shortY, shortU, initY, shortX);
    contribTbl = [];
    if options.Contributions
        contribTbl = this.tabulateContributions(contribs, fcastSpan);
    end

end%

