classdef MFVARsettings < bear.settings.BASEsettings
    %MFVARsettings Mixed frequency VAR settings class
    %   The bear.settings.MFVARsettings class is a class that creates a
    %   settings object to run a Mixed frequency VAR. It can be created
    %   directly by running:
    %
    %   bear.settings.MFVARsettings(ExcelPath, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('mfvar', ExcelPath = 'path/To/file.xlsx')
    %
    % MFVARsettings Properties:  
    %    ar              - auto-regressive coefficients
    %    lambda1         - hyperparameter
    %    lambda2         - hyperparameter
    %    lambda3         - hyperparameter
    %    lambda4         - hyperparameter
    %    lambda5         - hyperparameter
    %    lambda6         - hyperparameter
    %    lambda7         - hyperparameter
    %    lambda8         - hyperparameter
    
    properties % Hyperparameters
        % Autoregressive coefficient: ar
        ar (:,1) double = 0.9; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
        % Overall tightness: lambda1
        lambda1 (1,1) double {mustBeGreaterThanOrEqual(lambda1,0)} = 0.1;
        % Cross-variable weighting: lambda2
        lambda2 (1,1) double {mustBeGreaterThanOrEqual(lambda2,0.1)} = 3.4;
        % Lag decay: lambda3
        lambda3 (1,1) double {mustBeGreaterThanOrEqual(lambda3,1), mustBeLessThanOrEqual(lambda3,2)} = 1;
        % Exogenous variable and constant: lambda4
        lambda4 (:,1) double {mustBeGreaterThanOrEqual(lambda4,0)} = 3.4;
        % Block exogeneity shrinkage: lambda5
        lambda5 (1,1) double = 14.763158;
        % Sum-of-coefficients tightness: lambda6
        lambda6 (1,1) double {mustBeGreaterThanOrEqual(lambda6,0)} = 1;
        % Dummy initial observation tightness: lambda7
        lambda7 (1,1) double {mustBeGreaterThanOrEqual(lambda7,0)} = 0.01;
        % Long-run prior tightness : lambda8
        lambda8 (1,1) double = 1;        
    end
    
    methods
        
        function obj = MFVARsettings(excelPath, varargin)

            obj@bear.settings.BASEsettings(7, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end

end