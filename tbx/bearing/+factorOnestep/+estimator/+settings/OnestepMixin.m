
classdef OnestepMixin

    properties
        % Loading Variance
        % L0
        LoadingVariance double = 1

        % Sigma shape
        % a0
        SigmaShape double = 3

        % Sigma scale
        % b0
        SigmaScale double = 1e-3
    end

end

