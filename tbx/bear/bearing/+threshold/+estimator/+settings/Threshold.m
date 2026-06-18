
classdef (CaseInsensitiveProperties=true) Threshold ...
    < threshold.estimator.Settings

    properties
        % VarThreshold  Prior variance of the threshold
        VarThreshold (1, 1) double = 10

        % MaxDelay  Maxium delay allowed for the threshold variable for regime identification
        MaxDelay (1, 1) double {mustBeInteger, mustBePositive} = 4

        % ThresholdPropStd  Proposal standard deviation of the MH algoruthm of the threshold draws
        ThresholdPropStd (1, 1) double = sqrt(0.001)
    end

end

