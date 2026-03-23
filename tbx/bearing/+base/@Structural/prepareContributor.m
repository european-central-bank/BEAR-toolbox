
function [contributor, precontribs] = prepareContributor(this, span, precontribTbl)

    numPresampled = this.NumPresampled;
    meta = this.Meta;
    order = meta.Order;

    % No precontributions
    if isempty(precontribTbl)
        precontribs = double.empty(0, 0, 0, numPresampled);
        contributor = @calculateContributions4S_;
        return
    end

    startPeriod = span(1);
    precontribStart = meta.ShortStart;
    precontribEnd = datex.shift(startPeriod, -1);
    precontribSpan = datex.span(precontribStart, precontribEnd);
    precontribs = tablex.retrieveData( ...
        precontribTbl, meta.EndogenousNames, precontribSpan, ...
        variant=':', ...
        permute=[1, 4, 3, 2] ...
    );
    histInitYX = this.getInitYX();
    histInitY = histInitYX{1};
    numY = size(histInitY, 2);
    numContrib = size(precontribs, 3);
    precontribs = [zeros(order, numY, numContrib, numPresampled); precontribs];
    for i = 1 : numPresampled
        precontribs(1:order, :, end, i) = histInitY(:, :, min(end, i));
    end

    precontribs = precontribs(end-order+1:end, :, :, :);
    contributor = @extendPrecontributions4S_;

end%


function contrib = calculateContributions4S_(A, C, D, shortU, shortX, initY, ~)
    CONTRIB_DIM = 3;
    shortE = system.shocksFromResiduals(shortU, D);
    ce = system.contributionsShocks(A, D, shortE);
    cx = system.contributionsExogenous(A, C, shortX);
    ci = system.contributionsInit(A, initY);
    contrib = cat(CONTRIB_DIM, ce, cx, ci);
end%


function contrib = extendPrecontributions4S_(A, C, D, shortU, shortX, initY, precontribs)
    CONTRIB_DIM = 3;
    shortE = system.shocksFromResiduals(shortU, D);
    numE = size(shortE, 2);
    initContE = precontribs(:, :, 1:numE);
    initContX = precontribs(:, :, numE+1);
    initContI = precontribs(:, :, numE+2);
    ce = system.contributionsShocks(A, D, shortE, initContE);
    cx = system.contributionsExogenous(A, C, shortX, initContX);
    ci = system.contributionsInit(A, initContI);
    contrib = cat(CONTRIB_DIM, ce, cx, ci);
end%

