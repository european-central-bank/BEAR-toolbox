%{
%
% simulate  Simulate a finite VMA representation of a VAR model
%
% Syntax
% -------
%
%     Y = simulate(BB, D, order)
%
% Input arguments
% ----------------
%
%
% Output arguments
% -----------------
%
%
% Description
% ------------
%
%
% Example
% --------
%
%}


function Y = simulateFiniteVMA(AA, D)

    arguments
        AA (:, 1) cell
        D (:, :) double
    end

    numT = numel(AA);
    numY = size(AA{1}, 2);

    numL = size(AA{1}, 1);
    order = numL / numY;
    if order ~= round(order)
        error("The number of rows in the coefficient matrices must be a multiple of the number of columns");
    end

    numE = size(D, 1);
    Y = zeros(numT, numY, numE);

    l = zeros(numE, numL);

    y = D;
    Y(1, :, :) = permute(y, [3, 2, 1]);
    l = [y, l(:, 1:end-numY)];

    for t = 2 : numT
        y = l * AA{t};
        Y(t, :, :) = permute(y, [3, 2, 1]);
        l = [y, l(:, 1:end-numY)];
    end

end%

