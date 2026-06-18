
function [flag, absMaxEigval] = stabilityForVectorized(vecAs, numY, order, threshold)

    numPeriods = size(vecAs, 2);
    absMaxEigval = nan(numPeriods, 1);

    if isequal(threshold, Inf)
        flag = true;
        return
    end

    for t = 1 : numPeriods
        A = reshape(vecAs(:, t), [], numY);
        AA = [A, ];
        absMaxEigval(t) = abs(eigs(AA, 1));
        if absMaxEigval(t) > threshold
            flag = false;
            return
        end
    end

    flag = true;

end%

