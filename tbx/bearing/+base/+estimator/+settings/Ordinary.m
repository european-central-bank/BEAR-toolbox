
classdef (CaseInsensitiveProperties=true) Ordinary ...
    < base.estimator.Settings

    properties
        % FixedBeta  Keep coefficients fixed when sampling from posterior
        FixedBeta (1, 1) logical = false

        % FixedSigma  Keep Sigma fixed when sampling from posterior
        FixedSigma (1, 1) logical = false
    end

end

