
classdef (CaseInsensitiveProperties=true) NormalWishart ...
    < base.estimator.Settings

    properties
        % Method of calculating priors on covariance matrix ("ar" or "eye")
        % prior =21  and 22 respectively
        Sigma (1, 1) string {ismember(Sigma, ["ar", "eye"])} = "ar" %prior =21  and 22 in BEAR5
    end

end

