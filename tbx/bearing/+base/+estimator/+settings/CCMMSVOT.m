
classdef (CaseInsensitiveProperties=true) CCMMSVOT ...
    < base.estimator.settings.CCMMSVO

    properties
        % Lower bound of the uniform prior on degrees of freedom for inverse gamma (Q diagonal);
        DoFLowerBound (1,1) double = 3 % lower bound of degrees of freedom for the Student-t residuals

         % Upper bound of the uniform prior on degrees of freedom for inverse gamma (Q diagonal);
        DoFUpperBound (1,1) double = 40 % upper bound of degrees of freedom for the Student-t residuals
    end

end

