classdef PANELsettings < bear.settings.BASEsettings
    %PANELSETTINGS Panel VAR settings class
    %   The bear.settings.PANELsettings class is a class that creates a
    %   settings object to run a Panel VAR. It can be created directly by
    %   running:
    %
    %   bear.settings.PANELsettings(ExcelPath, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('panel', ExcelPath = 'path/To/file.xlsx')
    %
    % PANELsettings Properties:
    %    panel     - Choice of panel model
    %    unitnames - units
    %    It        - Gibbs sampler iterations
    %    Bu        - Gibbs sampler burn-in iterations
    %    pick      - retain only one post burn iteration
    %    pickf     - frequency of iteration picking
    %    ar        - autoregressive coefficient
    %    lambda1   - hyperparameter
    %    lambda2   - hyperparameter
    %    lambda3   - hyperparameter
    %    lambda4   - hyperparameter
    %    s0        - hyperparameter
    %    v0        - hyperparameter
    %    alpha0    - hyperparameter
    %    delta0    - hyperparameter
    %    gama      - hyperparameter
    %    a0        - hyperparameter
    %    b0        - hyperparameter
    %    rho       - hyperparameter
    %    psi       - hyperparameter

    properties
        % Choice of panel model: 
        % 1 = OLS mean group estimator (Mge),
        % 2 = pooled estimator (Pooled) 
        % 3 = random effect Zellner and Hong (Random_zh),
        % 4 = random effect hierarchical (Random_hierarchical) 
        % 5 = static factor approach (Factor_static)
        % 6 = dynamic factor approach (Factor_dynamic)
        panel (1,1) bear.PANELtype = 2;
        % units; must be single sstring, with names separated by a space
        unitnames='US EA UK';
        % total number of iterations for the Gibbs sampler
        It=2000;
        % number of burn-in iterations for the Gibbs sampler
        Bu=1000;
        % choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
        pick=0;
        % frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
        pickf=20;
        % hyperparameter: autoregressive coefficient
        ar=0.8;
        % hyperparameter: lambda1
        lambda1=0.1;
        % hyperparameter: lambda2
        lambda2=0.5;
        % hyperparameter: lambda3
        lambda3=1;
        % hyperparameter: lambda4
        lambda4=100;
        % hyperparameter: s0
        s0=0.001;
        % hyperparameter: v0
        v0=0.001;
        % hyperparameter: alpha0
        alpha0=1000;
        % hyperparameter: delta0
        delta0=1;
        % hyperparameter: gama
        gama=0.85;
        % hyperparameter: a0
        a0=1000;
        % hyperparameter: b0
        b0=1;
        % hyperparameter: rho
        rho=0.75;
        % hyperparameter: psi
        psi=0.1;
    end
    
    methods
        
        function obj = PANELsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(4, excelPath)           
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end