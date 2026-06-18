%{
%
% system.calculateResiduals  Calculate historical residuals
%
%}


function U = calculateResiduals(A, C, longY, longX, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        longY (:, :) double
        longX (:, :) double
        %
        options.HasIntercept (1, 1) logical
        options.Order (1, 1) double {mustBeInteger, mustBePositive}
    end

    hasIntercept = options.HasIntercept;
    order = options.Order;

    T = order+1 : size(longY, 1);
    numT = numel(T);

    % Extract the matrix of endogenous variables on the estimation span
    Y = longY(T, :);

    % Create the matrix of lagged endogenous variables
    L = [];
    for i = 1 : order
        L = [L, longY(T-i, :)];
    end

    % Extract the matrix of exogenous variables on the estimation span
    X = longX(T, :);
    X = system.addInterceptWhenNeeded(X, hasIntercept);

    % Calculate LHS-RHS residuals
    U = nan(size(Y));
    for t = 1 : numT
        U(t, :) = Y(t, :) - L(t, :) * A{t} - X(t, :) * C{t};
    end

end%

