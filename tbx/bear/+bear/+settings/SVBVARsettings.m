classdef SVBVARsettings < bear.settings.BASELINEsettings
    
    properties
        % choice of stochastic volatility model
        % 1=standard, 2=random scaling, 3=large BVAR %TVESLM Model
        stvol=4;
        % choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
        pick=0;
        % frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
        pickf=5;
        % block exogeneity (1=yes, 0=no)
        bex=0;
        % hyperparameter: autoregressive coefficient
        ar=0;
        % switch to Excel interface
        PriorExcel=0; % set to 1 if you want individual priors, 0 for default
        %switch to Excel interface for exogenous variables
        priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
        % total number of iterations for the Gibbs sampler
        It=2000;
        % number of burn-in iterations for the Gibbs sampler
        Bu=1000;
        %switch to Excel interface for exogenous variables
        % hyperparameter: lambda1
        lambda1=0.2;
        % hyperparameter: lambda2
        lambda2=0.7071;
        % hyperparameter: lambda3
        lambda3=1;
        % hyperparameter: lambda4
        lambda4=100;
        % hyperparameter: lambda5
        lambda5=0.001;
        % hyperparameter: gama
        gamma=1;
        % % hyperparameter: alpha0
        % alpha0=0.001;
        % % hyperparameter: delta0
        % delta0=0.001;
        % % hyperparameter: gamma0
        % gamma0=0;
        % % hyperparameter: zeta0
        % zeta0=10000;
        % panel Bayesian VAR specific information: will be read only if VARtype=4
    end
    
    methods
        
        function obj = SVBVARsettings(excelPath, varargin)
            
            obj@bear.settings.BASELINEsettings(5, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end