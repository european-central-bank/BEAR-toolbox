
function [Y, LX] = addDummiesToData(Y, LX, dummiesYLX)

    arguments
        Y (:, :) double
        LX (:, :) double
        dummiesYLX (1, 2) cell
    end

    [dummiesY, dummiesLX] = dummiesYLX{:};
    Y = [Y; dummiesY];
    LX = [LX; dummiesLX];

end%

