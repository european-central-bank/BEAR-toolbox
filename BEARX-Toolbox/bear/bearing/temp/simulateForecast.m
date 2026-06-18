
function Y = simulateForecast(AA, BB, Y, D, E, opt)

    arguments
        BB (:, 1) cell
        initY (:, :) double
        Z (:, :) double
        E (:, :) double

        opt.order (1, 1) double {mustBeNonnegative, mustBeInteger}
    end

    order = opt.order;
    numT = numel(BB);
    numY = size(initY, 2);
    Y = zeros(numT, numY);

    l = transpose(flipud(initY));
    l = transpose(l(:));

    for t = 1 : numT
        B = BB{t};
        z = Z(t, :);
        x = [l, z];
        y = x * B;
        Y(t, :) = y;
        l = [y, l(:, 1:end-numY)];
    end

end%

