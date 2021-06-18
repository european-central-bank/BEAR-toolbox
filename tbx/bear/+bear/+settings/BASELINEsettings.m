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
        favar = struct('FAVAR',0); % augment VAR model with factors (1=yes, 0=no)
        
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
        IRFt (1,1) double = 4;
        
        Feval (1,1) logical = false; % activate forecast evaluation (1=yes, 0=no)
        
        % type of conditional forecasts
        % 1=standard (all shocks), 2=standard (shock-specific)
        % 3=tilting (median), 4=tilting (interval)
        CFt = 1;
        
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
        
        function obj = set.favar(obj, value)
            
            obj.favar = value;
            
            % FAVAR options
            if obj.favar.FAVAR==1
                % transform information variables in excel sheet 'factor data' (following Stock & Watson: 1 Level, 2 First Difference, 3 Second Difference, 4 Log-Level, 5 Log-First-Difference, 6 Log-Second-Difference)
                obj.favar.transformation=1; % (1=yes, 0=no) // 'factor data' must contain values for startdate -1 in the case we have First Difference (2,5) transformation types and startdate -2 in the case we have Second Difference (3,6) transformation types
                obj.favar.transform_endo='6 2'; %'2 6' transformation codes of varendo variables other than factors
                % standardises (information) data in excel sheets 'data' and 'factor data'
                obj.favar.standardise=1; % (1=yes (default), 0=no)
                % demeans (information) data in excel sheets 'data' and 'factor data'
                obj.favar.demean=1; % (1=yes, 0=no)
                % specify the ordering of endogenpous factors and variables
                obj.varendo = 'factor1 factor2 factor3 factor4 PUNEW FYFF';
                
                % blocks/categories (1=yes, 0=no), specify in excel sheet
                obj.favar.blocks=0;
                if obj.favar.blocks==0 % basic favar model without blocks (basically one block)
                    obj.favar.numpc=4; % choose number of factors (principal components) to include
                elseif obj.favar.blocks==1 % assign information variables to blocks
                    obj.favar.blocknames='slow fast'; % specify in excel sheet 'factor data'
                    obj.favar.blocknumpc='2 2'; %block-specific number of factors (principal components)
                end
                
                
                % specify information variables of interest (plot and excel output) (HD & IRFs)
                obj.favar.plotX='IPS10 PMCP LHEM LHUR';
                % (approximate) HD for information variables
                obj.favar.HD.plot=0; % (1=yes, 0=no)
                if obj.favar.HD.plot==1
                    obj.favar.HD.sumShockcontributions=0; % sum contributions over shocks (=1), or over variables (=0, standard), only for IRFt2,3\\this option makes no sense in IRFt4,6
                    obj.favar.HD.plotXblocks=1; % sum contributions of factors blockwise
                    obj.favar.HD.HDallsumblock=0; % include all components of HDall(=1) other than shock contributions, but display them sumed under blocks\shocks
                end
                % (approximate) IRFs for information variables
                obj.favar.IRF.plot=1; % (1=yes, 0=no)
                if obj.favar.IRF.plot==1
                    % choose shock(s) to plot
                    obj.favar.IRF.plotXshock  = obj.varendo;%'FEVDshock';%'FYFF'; % FYFF 'USMP' % we need this atm only for IRFt2,3 provide =varendo for all shocks; in IRFt456 the identified shocks are plotted
                    obj.favar.IRF.plotXblocks = 0;
                end
                % (approximate) FEVDs for information variables
                obj.favar.FEVD.plot=1; % (1=yes, 0=no)
                if obj.favar.FEVD.plot==1
                    % choose shock(s) to plot
                    obj.favar.FEVD.plotXshock=obj.favar.IRF.plotXshock;%'EA.factor1 EA.factor2 EA.factor3 EA.factor4 EA.factor5 EA.factor6';
                end
            end
            
        end
        
    end
    
    methods (Access = protected)
        
        function obj = parseBEARSettings( obj, varargin )
            
            nInputs = numel(varargin);
            if rem(nInputs, 2) ~= 0
                error('bear:BASESettings:incorrectNumberOfInputs', 'You need to put an input for each output')
            end
            
            for i = 1 : 2 : nInputs
                try
                    obj.(varargin{i}) = varargin{i+1};
                catch e
                    if ~isprop(obj, varargin{i})
                        warning('bear:BaseSettings:SettingsDoesNotExist','The input %s does not exist, ignoring it', varargin{i})
                    else
                        rethrow(e)
                    end
                end
            end
            
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