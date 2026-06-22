classdef PANELsettings < bear.settings.BASEsettings
    %PANELSETTINGS Panel VAR settings class
    %   The bear.settings.PANELsettings class is a class that creates a
    %   settings object to run a Panel VAR. It can be created directly by
    %   running:
    %
    %   bear.settings.PANELsettings(ExcelFile, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('panel', ExcelFile = 'path/To/file.xlsx')
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
    %    gamma     - hyperparameter
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
        It (1,1) double {mustBeGreaterThanOrEqual(It,1)} = 2000;
        % number of burn-in iterations for the Gibbs sampler
        Bu (1,1) double = 1000;
        % choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
        pick=0;
        % frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
        pickf=20;
    end
    
    properties %Hyperparameters
        % hyperparameter: autoregressive coefficient
        ar (:,1) double = 0.8;
        % Overall tightness: lambda1
        lambda1 (1,1) double {mustBeGreaterThanOrEqual(lambda1,0)} = 0.1;
        % Cross-variable weighting: lambda2
        lambda2 (1,1) double {mustBeGreaterThanOrEqual(lambda2,0.1)} = 0.5;
        % Lag decay: lambda3
        lambda3 (1,1) double {mustBeInRange(lambda3, 1, 2)} = 1;
        % Exogenous variable and constant: lambda4
        lambda4 (:,:) double {mustBeGreaterThanOrEqual(lambda4,0)} = 100;
        % hyperparameter: s0
        s0 (1,1) double = 0.001;
        % hyperparameter: v0
        v0 (1,1) double = 0.001;
        % hyperparameter: alpha0
        alpha0 (1,1) double = 1000;
        % hyperparameter: delta0
        delta0 (1,1) double = 1;
        % hyperparameter: gamma
        gamma (1,1) double = 0.85;
        % hyperparameter: a0
        a0 (1,1) double = 1000;
        % hyperparameter: b0
        b0 (1,1) double = 1;
        % hyperparameter: rho
        rho (1,1) double = 0.75;
        % hyperparameter: psi
        psi (1,1) double = 0.1;
    end
    
    methods
        
        function obj = PANELsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(4, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
        function obj = set.panel(obj, value)
            
            obj.panel = value;
            try
                obj.checkIRFt(obj.IRFt);
            catch
                if ismember(value, [2, 3, 4])
                    obj.IRFt = bear.IRFtype(4);
                else
                    obj.IRFt = bear.IRFtype(1);
                end
            end
            
        end
        
        function obj = set.Bu(obj,value)
            if (value <= obj.It-1) %#ok<MCSUP>
                obj.Bu = value;
            else
                error('bear:settings:PANELsettings',"The maximum value of Bu is It-1: " + (obj.It-1)) %#ok<MCSUP>
            end
        end
        
        function obj = set.It(obj,value)
            if (value > obj.Bu-1) %#ok<MCSUP>
                obj.It = value;
            else
                error('bear:settings:PANELsettings',"The minimum value of It is Bu+1: " + (obj.Bu+1)) %#ok<MCSUP>
            end
        end
        
    end
    
    methods (Access = protected)
        
        function obj = checkIRFt(obj, value)
            
            switch value
                case {2, 3, 4}
                    if ~ismember(obj.panel, [2, 3, 4])
                        error('bear:settings:PANELsettings:WrongIRFt', ...
                            'For IRFt = 2, 3, 4 panel must be 2, 3, or 4');
                    end
                    
                case {5, 6}
                    error('bear:settings:PANELsettings:UnusedIRFt', ...
                        'PANEL VAR only works with IRFt = 1, 2, 3, 4');
            end
            
        end
        
        function value = getFEVD(obj)
            if obj.IRFt == 1
                value = 0;
            else
                value = obj.FEVDinternal;
            end
        end
        
        function value = getHD(obj)
            if obj.IRFt == 1
                value = 0;
            else
                value = obj.HDinternal;
            end
        end
        
    end
    
end