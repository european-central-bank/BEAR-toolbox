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
    %    ar              - autoregressive coefficient
    %    PriorExcel      - Select individual priors
    %    priorsexogenous - Gibbs sampler burn-in iterations
    %    It              - Gibbs sampler iterations
    %    Bu              - Gibbs sampler burn-in iterations
    %    lambda1         - hyperparameter
    %    lambda2         - hyperparameter
    %    lambda3         - hyperparameter
    %    lambda4         - hyperparameter
    %    lambda5         - hyperparameter
    %    gamma           - hyperparameter
    %    strctident      - strctident
    
    properties
        % Choice of stochastic volatility model
        % 1 = standard, 
        % 2 = random scaling
        % 3 = large BVAR %TVESLM Model
        stvol (1,1) bear.SVtype = 4;
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
        % strctident
        strctident
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