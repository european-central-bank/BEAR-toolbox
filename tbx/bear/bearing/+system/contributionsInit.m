
%{
%
% system.contributionsExogenous  Calculate contributions of exogenous variables
% to endogenous variables
%
%}

function contribs = contributionsInit(A, initY)

    arguments
        A (:, 1) cell {mustBeNonempty}
        initY (:, :, :) double
    end

    numT = numel(A);
    [order, numY] = system.orderFromA(A{1});
    numUnits = size(A{1}, 3);

    L = zeros(1, numY * order, 1, numUnits);
    for n = 1 : numUnits
        L(1, :, 1, n) = system.reshapeInit(initY(:, :, n));
    end

    permutedPulses = zeros(1, numY, 1, numUnits);

    contribs = system.filterPulses(A, permutedPulses, L);

end%

