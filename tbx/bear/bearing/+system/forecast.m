
%{
%
% system.forecast  Calculate forecast for reduced-form VARX model
%
%}

function [shortY] = forecast(A, C, initY, shortX, U, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        initY (:, :) double
        shortX (:, :) double
        U (:, :, :) double
        options.HasIntercept % (1, 1) logical
    end

    hasIntercept = options.HasIntercept;

    horizon = numel(A);
    numY = size(A{1}, 2);

    shortXI = system.addInterceptWhenNeeded(shortX, hasIntercept);


    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(shortXI, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    shortY = nan(horizon, numY);
    lt = system.reshapeInit(initY(:, :));
    for t = 1 : horizon
        yt = lt * A{t}(:, :) + shortXI(t, :) * C{t}(:, :) + U(t, :);
        lt = [yt, lt(:, 1:end-numY)];
        shortY(t, :) = yt;
    end

end%

