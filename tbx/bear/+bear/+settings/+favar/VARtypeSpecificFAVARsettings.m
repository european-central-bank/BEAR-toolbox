classdef VARtypeSpecificFAVARsettings < bear.settings.favar.FAVARsettings
    
    properties
        onestep (1,1) logical = 1; % Bayesian estimation of factors and the model in an one-step estimation (1=yes, 0=no (two-step))
        % thining of Gibbs draws
        thin = 1; % (=1 default, no thinning)
        % priors on factor equation
        % Loadings L~N(0,L0*eye)
        L0 = 1; %BBE set-up
        % Covariance Sigma~IG(a,b)
        a0 = 3; %BBE set-up
        b0 = 0.001; %BBE set-up
    end
    
end