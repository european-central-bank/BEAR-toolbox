%{
%
% system.forecastMA  Calculate forecast for reduced-form MA VARX model
%
%}

function [shortY, initY] = forecastMA(A, C, longYX, U, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        longYX (1, 2) cell
        U (:, :, :) double
        options.Order % (1, 1) double {mustBeInteger, mustBePositive}
    end

    order = options.Order;

    horizon = numel(A);
    [longY, longX] = longYX{:};
    numY = size(A{1}, 2);
    numUnits = size(A{1}, 3);

    shortXI = longX(order+1:end, :);

    initY = longY(1:order, :, :);
    initX = longX(1:order, :, :);
    

    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(shortXI, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    shortY = cell(1, numUnits);
    for n = 1 : numUnits
    
        shortY{n} = nan(horizon, numY);
        initSS = initX* C{1}(:, :, n); 
        lt = system.reshapeInit(initY(:, :, n) - initSS);

        for t = 1 : horizon
    
            sst = shortXI(t, :) * C{t}(:, :, n); 
            yt = lt * A{t}(:, :, n)  + U(t, :, n);
            lt = [yt, lt(:, 1:end-numY)];
            shortY{n}(t, :) = yt + sst;
        
        end
    
    end

    shortY = cat(3, shortY{:});

end%

