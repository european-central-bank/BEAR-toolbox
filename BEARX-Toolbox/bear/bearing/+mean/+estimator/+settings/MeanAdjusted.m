
classdef (CaseInsensitiveProperties=true) MeanAdjusted ...
    < mean.estimator.Settings

    properties 
        ScaleUp (1, 1) double = 100 
    end

end

