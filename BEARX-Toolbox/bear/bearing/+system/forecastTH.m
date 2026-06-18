%{
%
% system.forecastTH  Calculate forecast for Threshold VARX model
%
%}

function [shortY, shortU, initY, shortX] = forecastTH(A1, A2, C1, C2, initY, shortX, U1, U2, options)

    arguments
        A1 (:, 1) cell
        A2 (:, 1) cell
        C1 (:, 1) cell
        C2 (:, 1) cell
        initY(:, :) double
        shortX(:, :) double
        U1 (:, :, :) double
        U2 (:, :, :) double
        options.HasIntercept % (1, 1) logical
        options.Order % (1, 1) double {mustBeInteger, mustBePositive}
        options.Threshold
        options.ThresholdIndex
        options.Delay
    end

    hasIntercept = options.HasIntercept;
    threshold = options.Threshold;
    thresholdIndex = options.ThresholdIndex;
    delay = options.Delay;

    horizon = numel(A1);
    numY = size(A1{1}, 2);

    shortXI = system.addInterceptWhenNeeded(shortX, hasIntercept);

    if numel(C1) ~= horizon || size(U1, 1) ~= horizon ||numel(C2) ~= horizon || size(U2, 1) ~= horizon || size(shortXI, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    shortY = cell(1, 1);

    shortY{1} = nan(horizon, numY);
    lt = system.reshapeInit(initY(:, :));
    ind = thresholdIndex + (delay - 1)*numY;
    for t = 1 : horizon
        
        if lt(:, ind) <= threshold 
           A = A1{t}(:, :);
           C = C1{t}(:, :);
           shortU(t, :) = U1(t, :);
        else
           A = A2{t}(:, :);
           C = C2{t}(:, :);
           shortU(t, :) = U2(t, :);
        end

        yt = lt * A + shortXI(t, :) * C + shortU(t, :);
        lt = [yt, lt(:, 1:end-numY)];
        shortY{1}(t, :) = yt;
    end

    shortY = cat(3, shortY{:});

end%

