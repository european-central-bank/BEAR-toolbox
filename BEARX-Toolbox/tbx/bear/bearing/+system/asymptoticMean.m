
function ameanY = asymptoticMean(system, ameanX)

    A = system{1};
    C = system{2};
    numY = size(A, 2);
    order = size(A, 1) / numY;
    At = A';
    sumAt = sum(reshape(At, numY, numY, order), 3);
    sumA = sumAt';
    ameanY =  (ameanX * C) / (eye(numY) - sumA);

end%

