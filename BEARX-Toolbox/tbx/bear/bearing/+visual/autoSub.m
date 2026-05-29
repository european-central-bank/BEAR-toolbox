
function [numRows, numCols] = autoSub(numPlots)

    arguments
        numPlots (1, 1) double {mustBeInteger, mustBePositive}
    end

    numRows = ceil(sqrt(numPlots));
    if numRows * (numRows - 1) >= numPlots
        numCols = numRows - 1;
    else
        numCols = numRows;
    end

end%

