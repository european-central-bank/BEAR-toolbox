
function flag = stability(A, threshold)

    if isequal(threshold, Inf) || isequaln(threshold, NaN) || isempty(threshold)
        flag = true;
        return
    end

    numY = size(A, 2);
    order = size(A, 1) / numY;
    AA = [A, eye(numY*order, numY*(order - 1))];
    maxEigval = eigs(AA, 1);
    flag = abs(maxEigval) <= threshold;

end%

