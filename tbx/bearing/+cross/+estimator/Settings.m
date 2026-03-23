
classdef (Abstract, CaseInsensitiveProperties=true) Settings ...
    < base.estimator.Settings
    
    properties
        % IG shape on residual variance
        % alpha0
        Alpha0 (1, 1) double = 1000

        % IG scale on residual variance
        % delta0
        Delta0 (1, 1) double = 1
    end
    
    

end

