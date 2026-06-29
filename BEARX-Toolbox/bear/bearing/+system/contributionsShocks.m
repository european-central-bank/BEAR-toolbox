
%{
%
% system.contributionsShocks  Calculate contributions of shocks to endogenous variables
%
%}

function contribs = contributionsShocks(A, D, shortE, initContrib)

    arguments
        A (:, 1) cell {mustBeNonempty}
        D (:, :, :) double
        shortE (:, :, :) double
        initContrib (:, :, :) double = []
    end

    numUnits = size(A{1}, 3);
    if numUnits > 1
        error("Multiple units are not supported in system.contributionsShocks");
    end

    numT = numel(A);
    [order, numY] = system.orderFromA(A{1});
    numE = size(D, 1);
    numP = numE;
    numL = numY * order;

    L = zeros(numP, numL, 1);
    if nargin >= 4 && ~isempty(initContrib)
        for i = 1 : numP
            L(i, :, 1) = system.reshapeInit(initContrib(:, :, i));
        end
    end

    % TODO: Test performance against permutedPulses = cell(numT, 1);
    % permutedPulses is numE x numY x numT x numUnits to avoid unnecessary permute/ipermute
    permutedPulses = zeros(numE, numY, numT, numUnits);
    for n = 1 : numUnits
        for t = 1 : numT
            et = diag(shortE(t, :, n));
            permutedPulses(:, :, t, n) = et * D(:, :, n);
        end
    end

    % Contributions are numT x numY x numP x numUnits
    contribs = system.filterPulses(A, permutedPulses, L);

end%

