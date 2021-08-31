classdef SVsettings < bear.settings.BASEsettings
    %SVSETTINGS Panel VAR settings class
    %   The bear.settings.SVsettings class is a class that creates a
    %   settings object to run a stochastic volatility model. It can be created directly by
    %   running:
    %
    %   bear.settings.SVsettings(ExcelPath, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('SV', ExcelPath = 'path/To/file.xlsx')
    %
    % SVsettings Properties:
    %    stvol           - Choice of stochastic volatility model
    %    pick            - retain only one post burn iteration
    %    pickf           - frequency of iteration picking
    %    bex             - block exogeneity
    %    PriorExcel      - Select individual priors
    %    priorsexogenous - Gibbs sampler burn-in iterations
    %    It              - Gibbs sampler iterations
    %    Bu              - Gibbs sampler burn-in iterations
    %    strctident      - strctident
    %    ar              - autoregressive coefficient
    %    lambda1         - hyperparameter
    %    lambda2         - hyperparameter
    %    lambda3         - hyperparameter
    %    lambda4         - hyperparameter
    %    lambda5         - hyperparameter
    %    gamma           - hyperparameter
    %    alpha0          - hyperparameter
    %    delta0          - hyperparameter
    %    gamma0          - hyperparameter
    %    zeta0           - hyperparameter
    
    properties
        % Choice of stochastic volatility model
        % 1 = standard,
        % 2 = random scaling
        % 3 = large BVAR %TVESLM Model
        stvol (1,1) bear.SVtype = 4;
        % choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
        pick (1,1) logical = false;
        % frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
        pickf=5;
        % block exogeneity (1=yes, 0=no)
        bex (1,1) logical = false;
        % switch to Excel interface
        PriorExcel (1,1) logical = false; % set to 1 if you want individual priors, 0 for default
        %switch to Excel interface for exogenous variables
        priorsexogenous (1,1) logical = false; % set to 1 if you want individual priors, 0 for default
        % total number of iterations for the Gibbs sampler
        It=2000;
        % number of burn-in iterations for the Gibbs sampler
        Bu=1000;
        % strctident
        strctident
        %switch to Excel interface for exogenous variables
    end
    
    properties %Hyperparameters
        % Autoregressive coefficient: ar
        ar (:,1) double = 0; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
        % Overall tightness: lambda1
        lambda1 (1,1) double {mustBeGreaterThanOrEqual(lambda1,0)} = 0.2;
        % Cross-variable weighting: lambda2
        lambda2 (1,1) double {mustBeGreaterThanOrEqual(lambda2,0.1)} = sqrt(2)/2;
        % Lag decay: lambda3
        lambda3 (1,1) double {mustBeGreaterThanOrEqual(lambda3,1), mustBeLessThanOrEqual(lambda3,2)} = 1;
        % Exogenous variable and constant: lambda4
        lambda4 (:,1) double {mustBeGreaterThanOrEqual(lambda4,0)} = 100;
        % Block exogeneity shrinkage: lambda5
        lambda5 (1,1) double {mustBeGreaterThanOrEqual(lambda5,0), mustBeLessThanOrEqual(lambda5,1)} = 0.001;
        % AR coefficient on residual variance: gamma
        gamma (1,1) double = 1;
        % IG shape on residual variance: alpha0
        alpha0 (1,1) double = 0.001;
        % IG scale on residual variance: delta0
        delta0 (1,1) double = 0.001;
        % Prior mean of inertia parameter: gamma0
        gamma0 (1,1) double = 0;
        % Prior variance of inertia parameter: zeta0
        zeta0 (1,1) double = 10000;
    end
    
    methods
        
        function obj = SVsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(5, excelPath)
            
            obj = obj.setStrctident(obj.IRFt);
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
    methods (Access = protected)
        
        function obj = checkIRFt(obj, value)
            % we could call superclass method to combine effect
            obj = checkIRFt@bear.settings.BASEsettings(obj, value);
            obj = obj.setStrctident(value);
        end
        
    end
    
    methods (Access = private)
        
        function obj = setStrctident(obj, value)
            
            switch value
                case 4
                    obj.strctident = bear.settings.StrctidentIRFt4;
                case 5
                    obj.strctident = bear.settings.StrctidentIRFt5;
                case 6
                    obj.strctident = bear.settings.StrctidentIRFt6;
                otherwise
                    obj.strctident = bear.settings.Strctident.empty();
            end
            
        end
        
    end
    
end