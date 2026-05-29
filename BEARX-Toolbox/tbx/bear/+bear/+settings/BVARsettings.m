classdef BVARsettings < bear.settings.BASEsettings
    %BVARSETTINGS Panel VAR settings class
    %   The bear.settings.BVARsettings class is a class that creates a
    %   settings object to run a Bayesian VAR. It can be created directly by
    %   running:
    %
    %   bear.settings.BVARsettings(ExcelFile, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('bvar', ExcelFile = 'path/To/file.xlsx')
    %
    % BVARsettings Properties:
    %    prior           - Selected prior
    %    PriorExcel      - Select individual priors
    %    priorsexogenous - Gibbs sampler burn-in iterations
    %    It              - Gibbs sampler iterations
    %    Bu              - Gibbs sampler burn-in iterations
    %    hogs            - grid search
    %    bex             - block exogeneity
    %    scoeff          - apply sum of coefficients
    %    iobs            - initial observation
    %    lrp             - Long run prior option
    %    priorf          - scale of prior of factor f
    %    strctident      - strctident
    %    ar              - auto-regressive coefficients
    %    alpha0          - hyperparameter
    %    lambda1         - hyperparameter
    %    lambda2         - hyperparameter
    %    lambda3         - hyperparameter
    %    lambda4         - hyperparameter
    %    lambda5         - hyperparameter
    %    lambda6         - hyperparameter
    %    lambda7         - hyperparameter
    %    lambda8         - hyperparameter
    %    favar           - FAVAR options
    
    properties
        %prior Selected prior
        % 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
        % 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
        % 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
        % 41=Normal-diffuse
        % 51=Dummy observations
        % 61=Mean-adjusted
        prior (1,1) bear.PRIORtype = 11;
        % switch to Excel interface
        PriorExcel (1,1) logical = false; % set to 1 if you want individual priors, 0 for default
        %switch to Excel interface for exogenous variables
        priorsexogenous (1,1) logical = false; % set to 1 if you want individual priors, 0 for default
    end
    
    properties % Hyperparameters
        % Autoregressive coefficient: ar
        ar (:,1) double = 0.8; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
        % Overall tightness: lambda1
        lambda1 (1,1) double {mustBeGreaterThanOrEqual(lambda1,0)} = 0.1;
        % Cross-variable weighting: lambda2
        lambda2 (1,1) double {mustBeGreaterThanOrEqual(lambda2,0.1)} = 0.5;
        % Lag decay: lambda3
        lambda3 (1,1) double {mustBeInRange(lambda3, 1, 2)} = 1;
        % Exogenous variable and constant: lambda4
        lambda4 (:,:) double {mustBeGreaterThanOrEqual(lambda4,0)} = 100;
        % Block exogeneity shrinkage: lambda5
        lambda5 (1,1) double {mustBeInRange(lambda5,0, 1)} = 0.001;
        % Sum-of-coefficients tightness: lambda6
        lambda6 (1,1) double {mustBeGreaterThanOrEqual(lambda6,0)} = 0.1;
        % Dummy initial observation tightness: lambda7
        lambda7 (1,1) double {mustBeGreaterThanOrEqual(lambda7,0)} = 0.001;
        % Long-run prior tightness: lambda8
        lambda8 (1,1) double {mustBeInRange(lambda8,0, 100)} = 1;
    end
    
    properties
        % total number of iterations for the Gibbs sampler
        It (1,1) double {mustBeGreaterThanOrEqual(It,1)} = 1000;
        % number of burn-in iterations for the Gibbs sampler
        Bu (1,1) double = 500;
        % hyperparameter optimisation by grid search (1=yes, 0=no)
        hogs   (1,1) logical = false;
        % block exogeneity (1=yes, 0=no)
        bex    (1,1) logical = false;
        % sum-of-coefficients application (1=yes, 0=no)
        scoeff (1,1) logical = false;
        % dummy initial observation application (1=yes, 0=no)
        iobs   (1,1) logical = false;
        % Long run prior option
        lrp    (1,1) logical = false;
        % create H matrix for the long run priors
        % now taken from excel loadH.m
        % H=[1 1 0 0;-1 1 0 0;0 0 1 1;0 0 -1 1];
        % (61=Mean-adjusted BVAR) Scale up the variance of the prior of factor f
        priorf=100;
        % strctident
        strctident
        % hyperparameter: alpha0 Setting or result?
        alpha0=1000;
    end
    
    properties (Dependent)
        % FAVAR options
        favar % augment VAR model with factors (1=yes, 0=no)
    end
    
    properties (Access = private)
        favarInternal (1,1) bear.settings.favar.FAVARsettings = bear.settings.favar.VARtypeSpecificFAVARsettings; % augment VAR model with factors (1=yes, 0=no)
    end
    
    methods
        
        function obj = BVARsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(2, excelPath)
            
            obj = obj.setStrctident(obj.IRFt);
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
        function obj = set.Bu(obj,value)
            if (value <= obj.It-1) %#ok<MCSUP>
                obj.Bu = value;
            else
                error('bear:settings:BVARsettings',"The maximum value of Bu is It-1: " + (obj.It-1)) %#ok<MCSUP>
            end
        end
        
        function obj = set.It(obj,value)
            if (value > obj.Bu-1) %#ok<MCSUP>
                obj.It = value;
            else
                error('bear:settings:BVARsettings',"The minimum value of It is Bu+1: " + (obj.Bu+1)) %#ok<MCSUP>
            end
        end
        
        function value = get.favar(obj)
            
            if obj.prior == 61
                value = bear.settings.favar.NullFAVAR;
            else
                value = obj.favarInternal;
            end
            
        end
        
        function obj = set.favar(obj, value)
            
            if obj.prior == 61
                error('bear:settings:BVARsettings:undefinedFAVAR', ...
                    'It is not possible to set FAVAR if prior is Mean adjusted (61)')
            else
                obj.favarInternal = value;
            end
            
        end
        
        function obj = set.hogs(obj, value)
            if ismember(obj.prior, [11,12,13,21,22]) %#ok<MCSUP>
                obj.hogs = value;
            else
                if value
                    warning('bear:settings:BVARsettings:unusedHogs', ...
                        'Grid search is unused for the selected VARtype, setting it to false')
                end
                obj.hogs = false;
            end
        end
        
    end
    
    methods (Access = protected)
        
        function obj = checkIRFt(obj, value)
            obj = checkIRFt@bear.settings.BASEsettings(obj, value);
            obj = obj.setStrctident(value);
        end
        
    end

end
