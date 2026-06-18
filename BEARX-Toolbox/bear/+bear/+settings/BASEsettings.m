classdef (Abstract) BASEsettings < matlab.mixin.CustomDisplay
    %BASESETTINGS Abstract class with the common settings to all VARtypes
    %
    % BASEsettings Properties:
    %    frequency       - data frequency
    %    startdate       - sample start date
    %    enddate         - sample end date
    %    varendo         - endogenous variables;
    %    varexo          - exogenous variables
    %    lags            - number of lags
    %    const           - inclusion of a constant
    %    excelFile       - Excel file used for the inputs
    %    results_path    - path where there results file is stored
    %    results_sub     - name of the results file
    %    results         - save the results in the excel file (true/false)
    %    plot            - plot the results (true/false)
    %    workspace       - save the workspace as a .mat file (true/false)
    %    IRF             - impulse response functions
    %    IRFperiods      - number of periods for IRF
    %    F               - unconditional forecasts
    %    FEVD            - forecast error variance decomposition
    %    HD              - historical decomposition
    %    HDall           - plot the entire decomposition
    %    CF              - activate conditional forecasts
    %    IRFt            - structural identification
    %    Feval           - forecast evaluation
    %    CFt             - type of conditional forecasts
    %    Fstartdate      - start date for forecasts
    %    Fenddate        - start date for forecasts
    %    Fendsmpl        - start forecasts after the final sample period
    %    hstep           - step ahead evaluation
    %    window_size     - window_size for iterative forecasting
    %    evaluation_size - evaluation_size as percent of window_size
    %    cband           - confidence level for VAR coefficients
    %    IRFband         - confidence level for impusle response functions
    %    Fband           - confidence level for forecasts
    %    FEVDband        - confidence level for forecast error variance decomposition
    %    HDband          - confidence level for historical decomposition
    
    properties (SetAccess = private)
        
        VARtype   bear.VARtype = bear.VARtype.empty      % VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying)
        
    end
    
    properties
        %% App settings on constant panel
        frequency (1,1) double  = 2;                     % data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
        startdate               = '1974q1';              % sample start date; must be a string consistent with the date formats of the toolbox
        enddate                 = '2014q4';              % sample end date; must be a string consistent with the date formats of the toolbox
        varendo                 = 'YER HICSA STN';       % endogenous variables; must be a single string, with variable names separated by a space
        varexo                  = '';                    % exogenous variables, if any; must be a single string, with variable names separated by a space
        lags      (1,1) double  = 4;                     % number of lags
        const     (1,1) logical = true;                  % inclusion of a constant (1=yes, 0=no)
        
        excelFile    (1,:) char = '';                    % Excel file used for the inputs
        results_path (1,:) char = '';                    % path where there results file is stored
        results_sub  (1,:) char = 'results';             % name of the results file
        results      (1,1) logical = true;               % save the results in the excel file (true/false)
        plot         (1,1) logical = true;               % plot the results (true/false)
        workspace    (1,1) logical = true;               % save the workspace as a .mat file (true/false)
        
        % Model options
        IRF        (1,1) logical = true;  % activate impulse response functions (1=yes, 0=no)
        IRFperiods (1,1) double  = 20;    % number of periods for impulse response functions
        % structural identification:
        % 1=none,
        % 2=Cholesky,
        % 3=triangular factorisation
        % 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
        % 5=IV identification,
        % 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
        IRFt  bear.IRFtype = bear.IRFtype(2);
    end
    
    properties (Dependent)
        FEVD       % activate forecast error variance decomposition (1=yes, 0=no)
        HD         % activate historical decomposition (1=yes, 0=no)
    end
    
    properties
        
        HDall      (1,1) logical = 0;     % if we want to plot the entire decomposition, all contributions (includes deterministic part) (1=yes, 0=no)
        F          (1,1) logical = true;  % activate unconditional forecasts (1=yes, 0=no)
        
        CF         (1,1) logical = false; % activate conditional forecasts (1=yes, 0=no)
        % type of conditional forecasts
        % 1 = standard (all shocks),
        % 2 = standard (shock-specific)
        % 3 = tilting (median), 4=tilting (interval)
        CFt bear.CFtype = bear.CFtype(1);
        
        % start forecasts immediately after the final sample period (1=yes, 0=no)
        % has to be set to 1 if start date for forecasts is not in-sample
        Fendsmpl (1,1) logical = false;
        Fstartdate = '2014q1'; % start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
        Fenddate   = '2016q4'; % end date for forecasts
        Feval (1,1) logical = false; % activate forecast evaluation (1=yes, 0=no)
        
        hstep           (1,1) double = 1;    % step ahead evaluation
        window_size     (1,1) double = 0;    % window_size for iterative forecasting 0 if no iterative forecasting                                            <                                                                                    -
        evaluation_size (1,1) double = 0.5;  % evaluation_size as percent of window_size
        cband           (1,1) double = 0.68; % confidence/credibility level for VAR coefficients
        IRFband         (1,1) double = 0.68; % confidence/credibility level for impusle response functions
        Fband           (1,1) double = 0.68; % confidence/credibility level for forecasts
        FEVDband        (1,1) double = 0.68; % confidence/credibility level for forecast error variance decomposition
        HDband          (1,1) double = 0.68; % confidence/credibility level for historical decomposition
        
    end
    
    properties (Access = protected)
        FEVDinternal (1,1) logical = true;
        HDinternal   (1,1) logical = true;
    end
    
    
    methods
        
        function obj = BASEsettings(VARtype, excelPath)
            
            obj.VARtype = VARtype;
            obj.excelFile = excelPath;
            obj.results_path = pwd();
            
        end
        
        function obj = set.IRFt(obj, value)
            % call another function to check the value as desired,
            % and possibly even update it using some computation
            obj = checkIRFt(obj, value);
            
            % set set the property using the validated value
            % (only place we do assignment to avoid infinite recursion)
            obj.IRFt = value;
        end
        
        function value = get.FEVD(obj)
            value = getFEVD(obj);
        end
        
        function value = get.HD(obj)
            value = getHD(obj);
        end
        
        function obj = set.FEVD(obj, value)
            obj.FEVDinternal = value;
        end
        
        function obj = set.HD(obj, value)
            obj.HDinternal = value;
        end
        
    end
    
    methods (Access = protected)
        
        function obj = parseBEARSettings( obj, varargin )
            
            obj = bear.utils.pvset(obj, varargin{:});
            
        end
        
        function obj = checkIRFt(obj, ~)
        end
        
        function displayScalarObject(obj)
            
            % Grab property lists
            props = properties(obj)';
            meta = ?bear.settings.BASEsettings;
            
            % Get base properties
            baseProps = {meta.PropertyList.Name};
            
            specificProps = setdiff(props, baseProps);
            specificProps = props(ismember(props, specificProps)); % To keep original order
            
            mainProps = {'VARtype', 'frequency', 'startdate', ...
                'enddate', 'varendo', 'varexo', 'lags', 'const', ...
                'excelFile', 'results_path', 'results_sub', 'results', 'plot', 'workspace'};
            
            applicationProps = setdiff(baseProps, mainProps);
            applicationProps = props(ismember(props, applicationProps)); % To keep original order
            
            % header
            header = matlab.mixin.CustomDisplay.getSimpleHeader(obj);
            disp(header);
            
            % Preferences
            fprintf('\n <strong>--------- PREFERENCES ----------</strong>\n\n');
            mainProps = matlab.mixin.util.PropertyGroup(mainProps);
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, mainProps);
            
            % Specifications
            fprintf('\n <strong>--------- SPECIFICATIONS ----------</strong>\n\n');
            specificProps = matlab.mixin.util.PropertyGroup(specificProps);
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, specificProps);
            
            % Applications
            fprintf('\n <strong>--------- APPLICATIONS ----------</strong>\n\n');
            applicationProps = matlab.mixin.util.PropertyGroup(applicationProps);
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, applicationProps);
            
        end

        function obj = setStrctident(obj, value)
            
            switch value
                case 4
                    if class(obj.strctident) ~= "bear.settings.strctident.StrctidentIRFt4"
                        obj.strctident = bear.settings.strctident.StrctidentIRFt4(obj.strctident);
                    end
                case 5
                    if class(obj.strctident) ~= "bear.settings.strctident.StrctidentIRFt5"
                        obj.strctident = bear.settings.strctident.StrctidentIRFt5(obj.strctident);
                    end
                case 6
                    if class(obj.strctident) ~= "bear.settings.strctident.StrctidentIRFt6"
                        obj.strctident = bear.settings.strctident.StrctidentIRFt6(obj.strctident);
                    end
                otherwise
                    obj.strctident = bear.settings.strctident.Strctident.empty();
            end

        end
        
    end
    
    methods (Access = protected)
        
        function value = getFEVD(obj)
            value = obj.FEVDinternal;
        end
        
        function value = getHD(obj)
            value = obj.HDinternal;
        end
        
    end
    
end
