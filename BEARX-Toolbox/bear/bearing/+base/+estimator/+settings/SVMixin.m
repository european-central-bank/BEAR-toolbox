
classdef (CaseInsensitiveProperties=true) SVMixin

    properties
        % AR coefficient on residual variance
        % gamma
        HeteroskedasticityAutoRegression double = 1 %gamma

        % IG shape on residual variance
        % alpha0
        HeteroskedasticityShape double = 1e-3 %alpha

        % IG scale on residual variance
        % delta0
        HeteroskedasticityScale double = 1e-3 %delta
    end

end

