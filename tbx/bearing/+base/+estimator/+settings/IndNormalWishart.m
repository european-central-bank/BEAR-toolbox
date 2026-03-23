
classdef (CaseInsensitiveProperties=true) IndNormalWishart ...
    < base.estimator.Settings

    properties
        % Method of calculating priors on covariance matrix (ar;eye)
        % prior = 31 and 32 respectively
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar" %prior = 31 and 32 respectively
    end

end

