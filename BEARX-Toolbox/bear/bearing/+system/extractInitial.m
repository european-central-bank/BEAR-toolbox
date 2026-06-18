
function init = extractInitial(YLX)

    [Y, L, X] = YLX{:};

    numY = size(Y, 2);
    order = size(L, 2) / numY;
    if round(order) ~= order
        error("Inconsistent dimensions of Y and L data arrays")
    end

    init = transpose(reshape(L(1, :), numY, order));
    init = init(end:-1:1, :);

end%
