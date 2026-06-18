
%randominertia model, stvol=2 in bear5

classdef (CaseInsensitiveProperties=true) RandomInertiaSV ...
    < base.estimator.EstimatorSettings ...
    & base.estimator.settings.SVMixin

    properties
        % Prior variance of inertia
        % zeta0
        HeteroskedasticityAutoRegressionVariance double = 1e-2 %zeta0
    end

end


