
classdef (CaseInsensitiveProperties=true) GenLargeShockSV ...
    < base.estimator.Settings

    properties
        %Initial mean of scaling factors
        Mult0 double

        %Scale on covariance scaling factors' Pareto distribution
        ScaleMult double  

        %Shape on covariance scaling factors ' Pareto distribution
        ShapeMult double  

        %Scaling factors proposal std
        PropStdMult double 

        %Scaling factor's AR parameter's initial mean
        MultAR0 (1,1) double {mustBeGreaterThanOrEqual(MultAR0, 0), mustBeLessThanOrEqual(MultAR0, 1)} = 0.5

        %Scaling factor's AR parameter's alpha value in beta  
        AlphaMultAR (1,1) double

        %Scaling factor's  AR parameter's beta value in beta  
        BetaMultAR (1,1) double 

        %Scaling factors's  AR parameter's proposal std
        PropStdAR (1,1) double

        %Start date of the high-volatility period
        Turningpoint (1,1) datetime
    end

end



