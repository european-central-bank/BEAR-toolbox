classdef TVPsettings < bear.settings.BASEsettings
    %TVPSETTINGS Panel VAR settings class
    %   The bear.settings.TVPsettings class is a class that creates a settings
    %   object to run a time-varying VAR. It can be created directly by
    %   running:
    %
    %   bear.settings.TVPsettings(ExcelFile, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('TVP', ExcelFile = 'path/To/file.xlsx')
    %
    % TVPsettings Properties:
    %    tvbvar          - choice of time-varying BVAR model
    %    It              - Gibbs sampler iterations
    %    Bu              - Gibbs sampler burn-in iterations
    %    pick            - retain only one post burn iteration
    %    pickf           - frequency of iteration picking    
    %    ar              - auto-regressive coefficients
    %    PriorExcel      - Select individual priors
    %    priorsexogenous - Gibbs sampler burn-in iterations
    %    lambda4         - hyperparameter
    %    gamma           - hyperparameter
    %    alpha0          - hyperparameter
    %    delta0          - hyperparameter
    %    alltirf         - calculate IRFs for every sample period
    %    favar           - FAVAR Options
    
    properties
        % choice of time-varying BVAR model
        % 1 = time-varying coefficients (TVP)
        % 2 = general time-varying (TVP_SV)
        tvbvar (1,1) bear.TVPtype = 2;
        % switch to Excel interface
        PriorExcel (1,1) logical = false; % set to 1 if you want individual priors, 0 for default
        % switch to Excel interface for exogenous variables
        priorsexogenous (1,1) logical = true; % set to 1 if you want individual priors, 0 for default
        % hyperparameter: lambda4
        lambda4=100;
    end
    
    properties %Hyperparameters
        % hyperparameter: gamma
        gamma (1,1) double = 0.85;
        % hyperparameter: alpha0
        alpha0 (1,1) double = 0.001;
        % hyperparameter: delta0
        delta0 (1,1) double = 0.001;
        % calculate IRFs for every sample period (1=yes, 0=no)
        alltirf (1,1) logical = true;
    end
    
    properties
        % total number of iterations for the Gibbs sampler
        It (1,1) double {mustBeGreaterThanOrEqual(It,1)} = 2000;
        % number of burn-in iterations for the Gibbs sampler
        Bu (1,1) double = 1000;
        % choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
        pick (1,1) logical = false;
        % frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
        pickf=20;
        % just for the code to run (do not touch)
        ar=0;        
    end
    
    properties % FAVAR
        % FAVAR options
        favar (1,1) bear.settings.favar.FAVARsettings = bear.settings.favar.VARtypeSpecificFAVARsettings; % augment VAR model with factors (1=yes, 0=no)
    end
    
    methods
        
        function obj = TVPsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(6, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
        function obj = set.Bu(obj,value)
            if (value <= obj.It-1) %#ok<MCSUP>
                obj.Bu = value;
            else
                error('bear:settings:TVPsettings',"The maximum value of Bu is It-1: " + (obj.It-1)) %#ok<MCSUP>
            end
        end
        
        function obj = set.It(obj,value)
            if (value > obj.Bu-1) %#ok<MCSUP>
                obj.It = value;
            else
                error('bear:settings:TVPsettings',"The minimum value of It is Bu+1: " + (obj.Bu+1)) %#ok<MCSUP>
            end
        end
        
    end
    
end