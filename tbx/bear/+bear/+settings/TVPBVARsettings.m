classdef TVPBVARsettings < bear.settings.BASELINEsettings
    
    properties
        % choice of time-varying BVAR model
        % 1=time-varying coefficients, 2=general time-varying
        tvbvar=2;
        % total number of iterations for the Gibbs sampler
        It=200;
        % number of burn-in iterations for the Gibbs sampler
        Bu=100;
        % choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
        pick=0;
        % frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
        pickf=20;
        % calculate IRFs for every sample period (1=yes, 0=no)
        alltirf=1;
        % hyperparameter: gama
        gamma=0.85;
        % hyperparameter: alpha0
        alpha0=0.001;
        % hyperparameter: delta0
        delta0=0.001;
        % just for the code to run (do not touch)
        ar=0;
        PriorExcel=0;
        priorsexogenous=1;
        lambda4=100;
    end
    
    methods
        
        function obj = TVPBVARsettings(excelPath, varargin)
            
            obj@bear.settings.BASELINEsettings(6, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end