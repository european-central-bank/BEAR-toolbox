
classdef (CaseInsensitiveProperties=true) HierarchicalPanel ...
    < separable.estimator.Settings

    properties
        % IG shape on overall tightness
        % s0
        S0 (1, 1) double = 0.001

        % IG scale on overall tightness
        % v0
        V0 (1, 1) double = 0.001
    end

end

