
function tiles = getAutoTiles(numNames, maxNumTiles)

    arguments
        numNames (1, 1) double
        maxNumTiles (1, 1) double = Inf
    end

    num = min(numNames, maxNumTiles);
    numRows = ceil(sqrt(num));
    numCols = ceil(num / numRows);
    tiles = [numRows, numCols];

end%

