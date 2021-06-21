classdef (Abstract) BASELINEsettings
    
    properties
        
        VARtype   bear.VARtype = bear.VARtype.empty      % VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying)
        
        frequency (1,1) double  = 2;                     % data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
        startdate               = '1974q1';              % sample start date; must be a string consistent with the date formats of the toolbox
        enddate                 = '2014q4';              % sample end date; must be a string consistent with the date formats of the toolbox
        varendo                 = 'DOM_GDP DOM_CPI STN'; % endogenous variables; must be a single string, with variable names separated by a space
        varexo                  = '';                    % exogenous variables, if any; must be a single string, with variable names separated by a space
        lags      (1,1) double  = 4;                     % number of lags
        const     (1,1) logical = true;                  % inclusion of a constant (1=yes, 0=no)
        
        pref = struct();
        
        % FAVAR options
        favar (1,1) bear.settings.FAVARsettings = bear.settings.FAVARsettings(); % augment VAR model with factors (1=yes, 0=no)
        
        % Model options
        IRF        (1,1) logical = true;  % activate impulse response functions (1=yes, 0=no)
        IRFperiods (1,1) double  = 20;    % number of periods for impulse response functions
        F          (1,1) logical = true;  % activate unconditional forecasts (1=yes, 0=no)
        FEVD       (1,1) logical = true;  % activate forecast error variance decomposition (1=yes, 0=no)
        HD         (1,1) logical = true;  % activate historical decomposition (1=yes, 0=no)
        HDall      (1,1) double  = 0;     % if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
        CF         (1,1) logical = false; % activate conditional forecasts (1=yes, 0=no)
        
        % structural identification (1=none, 2=Cholesky, 3=triangular factorisation, 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
        %                            5=IV identification, 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
        IRFt  bear.IRFtype = bear.IRFtype(4);
        
        Feval (1,1) logical = false; % activate forecast evaluation (1=yes, 0=no)
        
        % type of conditional forecasts
        % 1=standard (all shocks), 2=standard (shock-specific)
        % 3=tilting (median), 4=tilting (interval)
        CFt bear.CFtype = bear.CFtype(1);
        
        Fstartdate = '2014q1'; % start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
        Fenddate   = '2016q4'; % end date for forecasts
        
        % start forecasts immediately after the final sample period (1=yes, 0=no)
        % has to be set to 1 if start date for forecasts is not in-sample
        Fendsmpl (1,1) logical = false;
        
        hstep           (1,1) double = 1;    % step ahead evaluation
        window_size     (1,1) double = 0;    % window_size for iterative forecasting 0 if no iterative forecasting                                            <                                                                                    -
        evaluation_size (1,1) double = 0.5;  % evaluation_size as percent of window_size
        cband           (1,1) double = 0.95; % confidence/credibility level for VAR coefficients
        IRFband         (1,1) double = 0.68; % confidence/credibility level for impusle response functions
        Fband           (1,1) double = 0.95; % confidence/credibility level for forecasts
        FEVDband        (1,1) double = 0.95; % confidence/credibility level for forecast error variance decomposition
        HDband          (1,1) double = 0.68; % confidence/credibility level for historical decomposition
        
    end

    methods
        
        function obj = BASELINEsettings(VARtype, excelPath)
            
            obj.VARtype = VARtype;
            obj.pref = iGetDefaultPref(excelPath);
            
        end

        function obj = set.IRFt(obj, value)
            % call another function to check the value as desired,
            % and possibly even update it using some computation
            obj = checkIRFt(obj, value);

            % set set the property using the validated value
            % (only place we do assignment to avoid infinite recursion)
            obj.IRFt = value;
        end
        
    end
    
    methods (Access = protected)
        
        function obj = parseBEARSettings( obj, varargin )
            
            obj = bear.utils.pvset(obj, varargin{:});
            
        end

        function obj = checkIRFt(obj, value)
            % Check values
            validateattributes(value, {'numeric', 'char', 'string', 'bear.IRFtype'}, {'scalar'});
        end
        
    end
    
end

function pref = iGetDefaultPref(excelPath)
% path to data; must be a single string
pref.datapath  = bearroot(); % main BEAR folder, specify otherwise
pref.excelFile = excelPath;
% excel results file name
pref.results_sub='results_test_data_61_temp';
% to output results in excel
pref.results=0;
% output charts
pref.plot=0;
% pref: useless by itself, just here to avoid code to crash
pref.pref=0;
% save matlab workspace (1=yes, 0=no (standard))
pref.workspace=1;
end