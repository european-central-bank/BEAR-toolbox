
function [numY, numL, numX, numT, order] = getDimensionsFromYLX(YLX)
    [Y, L, X] = YLX{:};
    numY = size(Y, 2);
    numL = size(L, 2);
    numX = size(X, 2);
    numT = size(Y, 1);
    order = numL / numY;
    if order ~= round(order)
        message = join([
            "The number of columns in lagged endogenous data matrix L (%g)"
            "is inconsistent with the number of columns in the endogenous data matrix Y (%g)"
        ], " ");
        error(message, numL, numY);
    end
end%

