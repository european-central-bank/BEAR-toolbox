
function out = wrapInStabilityCheck(options)

    arguments
        options.Sampler function_handle 
        options.Retriever function_handle
        options.Threshold (1, 1) double
        options.NumY (1, 1) double
        options.Order (1, 1) double
        options.NumPeriodsToCheck (1, 1) double
        options.MaxNumAttempts (1, 1) double
    end

    threshold = options.Threshold;
    sampler = options.Sampler;

    if ~isfinite(threshold) || threshold <= 0
        out = sampler;
        return
    end

    retriever = options.Retriever;
    numY = options.NumY;
    order = options.Order;
    numPeriodsToCheck = options.NumPeriodsToCheck;
    maxNumAttempts = options.MaxNumAttempts;

    ident = eye(numY*order, numY*(order - 1));

    function [flag, absMaxEigval] = checkStability_(sample)
        absMaxEigval = nan(numPeriodsToCheck, 1);
        for t = 1 : numPeriodsToCheck
            A = retriever(sample, t);
            AA = [A, ident];
            absMaxEigval(t) = abs(eigs(AA, 1));
            if absMaxEigval(t) > threshold
                flag = false;
                return
            end
        end
        flag = true;
    end%

    function sample = samplerWrappedInStabilityCheck()
        numAttempts = 0;
        while true
            sample = sampler();
            [flag, absMaxEigval] = checkStability_(sample);
            if flag
                break
            end
            numAttempts = numAttempts + 1;
            if numAttempts > maxNumAttempts
                error("Stability check failed after %d attempts. Please check your model specification.", numAttempts);
            end
        end
        sample.AbsMaxEigval = absMaxEigval;
        sample.NumAttempts = numAttempts;
    end%

    out = @samplerWrappedInStabilityCheck;

end%

