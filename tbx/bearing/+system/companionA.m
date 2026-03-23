
function AA = companionA(A)

    numY = size(A, 2);
    order = size(A, 1) / numY;
    AA = [A, eye(numY*order, numY*(order - 1))];

end%
