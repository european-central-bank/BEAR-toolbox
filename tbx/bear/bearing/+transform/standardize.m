
function [standardizedX, storeMeanStd] = standardize(X)

    arguments 
        X (:, :) double
    end

    % numVariables = size(X, 2);
    [stdX, meanX] = std(X, 0, 1);
    standardizedX = (X - meanX) ./ stdX;

    % rowSplit = ones(numVariables, 1);
    % columnSplit = 2;

    meanX = reshape(meanX, [], 1);
    stdX = reshape(stdX, [], 1);

    storeMeanStd = {meanX, stdX};

end%

