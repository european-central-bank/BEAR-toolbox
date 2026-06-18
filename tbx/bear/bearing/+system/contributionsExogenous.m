
%{
%
% system.contributionsExogenous  Calculate contributions of exogenous variables
% to endogenous variables
%
%}

function contribs = contributionsExogenous(A, C, shortX, initContrib)

    arguments
        A (:, 1) cell {mustBeNonempty}
        C (:, 1) cell {mustBeNonempty}
        shortX (:, :, :) double
        initContrib (:, :) double = []
    end

    numUnits = size(A{1}, 3);
    if numUnits > 1
        error("Multiple units are not supported in system.contributionsExogenous");
    end

    numT = numel(A);
    [order, numY] = system.orderFromA(A{1});
    numL = numY * order;

    L = zeros(1, numL, 1);
    if nargin >= 4 && ~isempty(initContrib)
        L(1, :, 1) = system.reshapeInit(initContrib(:, :));
    end

    hasIntercept = size(C{1}, 1) == size(shortX, 2) + 1;
    shortX = system.addInterceptWhenNeeded(shortX, hasIntercept);

    permutedPulses = zeros(1, numY, numT);
    for t = 1 : numT
        permutedPulses(:, :, t) = shortX(t, :) * C{t};
    end

    contribs = system.filterPulses(A, permutedPulses, L);

end%

