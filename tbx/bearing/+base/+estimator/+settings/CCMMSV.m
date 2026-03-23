
classdef (CaseInsensitiveProperties=true) CCMMSV ...
    < base.estimator.Settings

    properties
        % Scaling factor controling the final prior scaling of the IW disribution of the heteroscedasticity parameter
        HeteroskedasticityScale (1,1) double = 0.15 %Controls the final prior scaling param in the IW distribution of the covariance matrix of
        % the error term of the RW of the heteroscedasticity parameter. The
        % final scalig parameter is this value  multiplied by the degress
        % of freedom which is set as a function of variables

        % Controls the latest point of the range for getting the mean prior for the B matrix
        Turningpoint (1,1) datetime %Used for setting the prior B, as the OLS for getting the prior mean B is estimated only up to this point
    end

end

