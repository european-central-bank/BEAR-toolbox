
function [order, numY] = orderFromA(A)

    % arguments
    %     A (:, :, :) double
    % end

    numY = size(A, 2);
    order = size(A, 1) / numY;
    if round(order) ~= order
        error("Invalid size of system matrix A");
    end

end%

