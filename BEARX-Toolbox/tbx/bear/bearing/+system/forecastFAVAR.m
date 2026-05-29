
%{
%
% system.forecastFAVAR  Calculate forecast for reduced-form FAVAR model
%
%}

function [shortY, initY, shortX] = forecastFAVAR(A, C, initY, longX, U, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        initY
        longX
        U (:, :, :) double
        options.HasIntercept % (1, 1) logical
        options.Order % (1, 1) double {mustBeInteger, mustBePositive}
    end

    hasIntercept = options.HasIntercept;
    order = options.Order;

    horizon = numel(A);
    numY = size(A{1}, 2);

    shortX = longX(order+1:end, :);
    shortXI = system.addInterceptWhenNeeded(shortX, hasIntercept);


    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(shortXI, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    shortY = cell(1, 1);
 
    shortY{1} = nan(horizon, numY);
    lt = system.reshapeInit(initY(:, :, 1));
    for t = 1 : horizon
        yt = lt * A{t}(:, :, 1) + shortXI(t, :) * C{t}(:, :, 1) + U(t, :, 1);
        lt = [yt, lt(:, 1:end-numY)];
        shortY{1}(t, :) = yt;
    end

    shortY = cat(3, shortY{:});

end%

