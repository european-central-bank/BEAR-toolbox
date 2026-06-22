classdef MFVARsettings < bear.settings.BASEsettings
    %MFVARsettings Mixed frequency VAR settings class
    %   The bear.settings.MFVARsettings class is a class that creates a
    %   settings object to run a Mixed frequency VAR. It can be created
    %   directly by running:
    %
    %   bear.settings.MFVARsettings(ExcelFile, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('mfvar', ExcelFile = 'path/To/file.xlsx')
    %
    % MFVARsettings Properties:  
    %    prior           - Selected prior
    %    It              - Gibbs sampler iterations
    %    Bu              - Gibbs sampler burn-in iterations
    %    hogs            - grid search
    %    bex             - block exogeneity
    %    scoeff          - apply sum of coefficients
    %    iobs            - initial observation
    %    lrp             - Long run prior option
    %    H               - H matrix
    %    ar              - auto-regressive coefficients
    %    lambda1         - hyperparameter
    %    lambda2         - hyperparameter
    %    lambda3         - hyperparameter
    %    lambda4         - hyperparameter
    %    lambda5         - hyperparameter
    
    properties
        %prior Selected prior
        % 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
        % 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
        % 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
        % 41=Normal-diffuse
        % 51=Dummy observations
        % 61=Mean-adjusted
        prior (1,1) bear.PRIORtype = 11;
        % total number of iterations for the Gibbs sampler
        It (1,1) double {mustBeGreaterThanOrEqual(It,1)} = 2000;
        % number of burn-in iterations for the Gibbs sampler
        Bu (1,1) double = 1000;
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
        H = 7;                      % how many monhtly forecast to do in the original MF-BVAR code. Can be replaced in the future with Fsample_end-Fsample_start from BEAR        
    end
    
    properties % Hyperparameters
        % Autoregressive coefficient: ar
        ar (:,1) double = 0.9; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
        % Overall tightness: lambda1
        lambda1 (1,1) double {mustBeGreaterThanOrEqual(lambda1,0)} = 0.1;
        % Cross-variable weighting: lambda2
        lambda2 (1,1) double {mustBeGreaterThanOrEqual(lambda2,0.1)} = 3.4;
        % Lag decay: lambda3
        lambda3 (1,1) double {mustBeInRange(lambda3, 1, 2)} = 1;
        % Exogenous variable and constant: lambda4
        lambda4 (:,1) double {mustBeGreaterThanOrEqual(lambda4,0)} = 3.4;
        % Block exogeneity shrinkage: lambda5
        lambda5 (1,1) double = 14.763158;     
        % Sum-of-coefficients tightness: lambda6
        lambda6 (1,1) double {mustBeGreaterThanOrEqual(lambda6,0)} = 1;
        % Dummy initial observation tightness: lambda7
        lambda7 (1,1) double {mustBeGreaterThanOrEqual(lambda7,0)} = 0.01;
        % Long-run prior tightness: lambda8
        lambda8 (1,1) double = 1;
    end
    
    methods
        
        function obj = MFVARsettings(excelPath, varargin)

            obj@bear.settings.BASEsettings(7, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end

end