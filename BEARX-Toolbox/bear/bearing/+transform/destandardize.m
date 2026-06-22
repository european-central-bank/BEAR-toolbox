
function X = destandardize(standardizedX, storeMeanStd)

    arguments
        standardizedX (:, :) double
        storeMeanStd (1, 2) cell
    end

    meanX = storeMeanStd{1};
    stdX = storeMeanStd{2};
    X = (standardizedX .* stdX) + meanX;

end%

