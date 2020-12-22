classdef interface_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BEAR                            matlab.ui.Figure
        REPLICATIONSMenu                matlab.ui.container.Menu
        SPECIFICATION                   matlab.ui.container.Menu
        APPLICATIONS                    matlab.ui.container.Menu
        BEARMenu                        matlab.ui.container.Menu
        RUNButton                       matlab.ui.control.Button
        VARtype                         matlab.ui.control.DropDown
        Interface_Initialisation        matlab.ui.container.Panel
        EnterthelistofendogenousvariablesLabel  matlab.ui.control.Label
        varendo                         matlab.ui.control.TextArea
        EnterthelistofexogenousvariablesLabel  matlab.ui.control.Label
        varexo                          matlab.ui.control.TextArea
        EstimationStartdateLabel        matlab.ui.control.Label
        startdate                       matlab.ui.control.EditField
        EstimationEnddateLabel          matlab.ui.control.Label
        enddate                         matlab.ui.control.EditField
        results                         matlab.ui.control.CheckBox
        plot                            matlab.ui.control.CheckBox
        SetresultsfileEditFieldLabel    matlab.ui.control.Label
        results_sub                     matlab.ui.control.EditField
        DataFrequencyDropDownLabel      matlab.ui.control.Label
        frequency                       matlab.ui.control.DropDown
        IncludeconstantSwitchLabel      matlab.ui.control.Label
        constant                        matlab.ui.control.Switch
        LagsLabel                       matlab.ui.control.Label
        lags                            matlab.ui.control.NumericEditField
        Interface_BEAR                  matlab.ui.container.Panel
        BEARpicture                     matlab.ui.control.Button
        Interface_Applications          matlab.ui.container.Panel
        Applicationoptions              matlab.ui.container.Panel
        ImpulseresponsefunctionsSwitchLabel  matlab.ui.control.Label
        IRF                             matlab.ui.control.Switch
        UnconditionalforecastsSwitchLabel  matlab.ui.control.Label
        F                               matlab.ui.control.Switch
        HistoricaldecompositionsSwitchLabel  matlab.ui.control.Label
        HD                              matlab.ui.control.Switch
        ConditionalforecastsSwitchLabel  matlab.ui.control.Label
        CF                              matlab.ui.control.Switch
        ForecasterrorvarianceSwitchLabel  matlab.ui.control.Label
        FEVD                            matlab.ui.control.Switch
        favarIRFplot                    matlab.ui.control.CheckBox
        favarFEVDplot                   matlab.ui.control.CheckBox
        favarHDplot                     matlab.ui.control.CheckBox
        Estimationoptions               matlab.ui.container.Panel
        ForecastevaluationsSwitchLabel  matlab.ui.control.Label
        Feval                           matlab.ui.control.Switch
        ForecaststepaheadevaluationsEditFieldLabel  matlab.ui.control.Label
        hstep                           matlab.ui.control.NumericEditField
        RollingWindow0forfullsampleEditFieldLabel  matlab.ui.control.Label
        window_size                     matlab.ui.control.NumericEditField
        EvaluationSizeEditFieldLabel    matlab.ui.control.Label
        evaluation_size                 matlab.ui.control.NumericEditField
        Periodoptions                   matlab.ui.container.Panel
        IRFperiodsEditFieldLabel        matlab.ui.control.Label
        IRFperiods                      matlab.ui.control.NumericEditField
        ForecastsafterlastsampleperiodSwitchLabel  matlab.ui.control.Label
        Fendsmpl                        matlab.ui.control.Switch
        ForecastsStartdateEditFieldLabel  matlab.ui.control.Label
        Fstartdate                      matlab.ui.control.EditField
        ForecastsEnddateLabel           matlab.ui.control.Label
        Fenddate                        matlab.ui.control.EditField
        VARcoefficientsEditFieldLabel   matlab.ui.control.Label
        cband                           matlab.ui.control.NumericEditField
        Structuralidentifications       matlab.ui.container.Panel
        ButtonGroup                     matlab.ui.container.ButtonGroup
        Noidentification                matlab.ui.control.RadioButton
        Choleskifactorisation           matlab.ui.control.RadioButton
        Triangularfactorisation         matlab.ui.control.RadioButton
        Signrestrictions                matlab.ui.control.RadioButton
        Proxy                           matlab.ui.control.RadioButton
        Proxysign                       matlab.ui.control.RadioButton
        TypesofconditionalforecastsButtongroup  matlab.ui.container.ButtonGroup
        Standardallshocks               matlab.ui.control.RadioButton
        Standardshockspecific           matlab.ui.control.RadioButton
        Tiltingmedian                   matlab.ui.control.RadioButton
        Tiltinginterval                 matlab.ui.control.RadioButton
        ProxyVars                       matlab.ui.container.Panel
        InstrumentLabel                 matlab.ui.control.Label
        InstrumentstartdateLabel        matlab.ui.control.Label
        startdateIV                     matlab.ui.control.EditField
        InstrumentEnddateLabel          matlab.ui.control.Label
        enddateIV                       matlab.ui.control.EditField
        Instrument                      matlab.ui.control.EditField
        FlatreducedformpriorLabel       matlab.ui.control.Label
        prior_type_reduced_form         matlab.ui.control.Switch
        HighrelevancepriorLabel         matlab.ui.control.Label
        prior_type_proxy                matlab.ui.control.Switch
        CorrelShockLabel                matlab.ui.control.Label
        Correlshock                     matlab.ui.control.EditField
        CorrelInstrumentLabel           matlab.ui.control.Label
        Correlinstrument                matlab.ui.control.EditField
        FAVARplotPanel                  matlab.ui.container.Panel
        PlotXLabel                      matlab.ui.control.Label
        plotX                           matlab.ui.control.EditField
        PlotXshockLabel                 matlab.ui.control.Label
        plotXshock                      matlab.ui.control.EditField
        Interface_BayesianVAR           matlab.ui.container.Panel
        BayesianVARPriorsOLSFAVARPanel  matlab.ui.container.Panel
        BayesianVARpriors               matlab.ui.control.DropDown
        OLS                             matlab.ui.control.CheckBox
        FAVAR                           matlab.ui.control.CheckBox
        HyperparametersPanel            matlab.ui.container.Panel
        AutoregressivecoefficientEditFieldLabel  matlab.ui.control.Label
        OveralltightnessEditFieldLabel  matlab.ui.control.Label
        CrossvariableweightingEditFieldLabel  matlab.ui.control.Label
        LagdecayEditFieldLabel          matlab.ui.control.Label
        BlockexogeneityshrinkageEditFieldLabel  matlab.ui.control.Label
        SumofcoefficientstightnessEditFieldLabel  matlab.ui.control.Label
        DummyinitialobservationtightnessEditFieldLabel  matlab.ui.control.Label
        LongrunpriortightnessEditFieldLabel  matlab.ui.control.Label
        ExogenousvariablesSwitchLabel   matlab.ui.control.Label
        priorexogenous                  matlab.ui.control.Switch
        lambda1                         matlab.ui.control.NumericEditField
        lambda2                         matlab.ui.control.NumericEditField
        lambda3                         matlab.ui.control.NumericEditField
        lambda5                         matlab.ui.control.NumericEditField
        lambda6                         matlab.ui.control.NumericEditField
        lambda7                         matlab.ui.control.NumericEditField
        lambda8                         matlab.ui.control.NumericEditField
        ar                              matlab.ui.control.NumericEditField
        PriorExcel                      matlab.ui.control.CheckBox
        OptionsPanel                    matlab.ui.container.Panel
        GridsearchonexcelSwitchLabel    matlab.ui.control.Label
        hogs                            matlab.ui.control.Switch
        BlockexogeneityonexcelSwitchLabel  matlab.ui.control.Label
        bex                             matlab.ui.control.Switch
        scoeff                          matlab.ui.control.CheckBox
        iobs                            matlab.ui.control.CheckBox
        lrp                             matlab.ui.control.CheckBox
        Dummyobservationextensions      matlab.ui.control.Label
        StochasticVolatilityTimevaryingTrendsPanel  matlab.ui.container.Panel
        ButtonGroup_4                   matlab.ui.container.ButtonGroup
        Standard                        matlab.ui.control.RadioButton
        RandomInertia                   matlab.ui.control.RadioButton
        LargeVAR                        matlab.ui.control.RadioButton
        VARcoefficientstime             matlab.ui.control.RadioButton
        Generaltime                     matlab.ui.control.RadioButton
        Stochastictrend                 matlab.ui.control.RadioButton
        IterationsPanel                 matlab.ui.container.Panel
        TotalnumberofiterationsEditFieldLabel_3  matlab.ui.control.Label
        NumberofburniniterationsEditFieldLabel_3  matlab.ui.control.Label
        It                              matlab.ui.control.NumericEditField
        Bu                              matlab.ui.control.NumericEditField
        HyperparametersstochasticPanel  matlab.ui.container.Panel
        IGshapeonresidualvariance       matlab.ui.control.Label
        IGscaleonresidualvariance       matlab.ui.control.Label
        ARcoefficientonresidualvariance  matlab.ui.control.Label
        Priormeanoninertia              matlab.ui.control.Label
        Priorvarianceoninertia          matlab.ui.control.Label
        alpha0                          matlab.ui.control.NumericEditField
        gamma                           matlab.ui.control.NumericEditField
        delta0                          matlab.ui.control.NumericEditField
        gamma0                          matlab.ui.control.NumericEditField
        zeta0                           matlab.ui.control.NumericEditField
        alltirf                         matlab.ui.control.CheckBox
        FAVAROptions                    matlab.ui.container.Panel
        FAVARtransformationlabel        matlab.ui.control.Label
        onesteplabel                    matlab.ui.control.Label
        transformation                  matlab.ui.control.Switch
        onestep                         matlab.ui.control.Switch
        TcodesendoLabel                 matlab.ui.control.Label
        transform_endo                  matlab.ui.control.EditField
        slowfastlabel                   matlab.ui.control.Label
        slowfast                        matlab.ui.control.Switch
        blockslabel                     matlab.ui.control.Label
        blocks                          matlab.ui.control.Switch
        BlocknamesLabel                 matlab.ui.control.Label
        blocknames                      matlab.ui.control.EditField
        BlocknofactorsLabel             matlab.ui.control.Label
        blocknumpc                      matlab.ui.control.EditField
        NofactorsLabel                  matlab.ui.control.Label
        numpc                           matlab.ui.control.EditField
        SetpathtodataTextArea           matlab.ui.control.Label
        datapath                        matlab.ui.control.TextArea
        Panel_Panel                     matlab.ui.container.Panel
        BayesianPanelVARsPriors         matlab.ui.container.Panel
        ButtonGroup_3                   matlab.ui.container.ButtonGroup
        Meangroup                       matlab.ui.control.RadioButton
        RandomEffectZellnerHong         matlab.ui.control.RadioButton
        StaticStructurefactor           matlab.ui.control.RadioButton
        PooledEstimator                 matlab.ui.control.RadioButton
        RandomEffectHierarchical        matlab.ui.control.RadioButton
        DynamicStructurefactor          matlab.ui.control.RadioButton
        HyperparametersPanel_panel      matlab.ui.container.Panel
        AutoregressivecoefficientEditFieldLabel_2  matlab.ui.control.Label
        OveralltightnessEditFieldLabel_2  matlab.ui.control.Label
        CrossvariableweightingEditFieldLabel_2  matlab.ui.control.Label
        LagdecayEditFieldLabel_2        matlab.ui.control.Label
        ExogenousvariabletightnessEditFieldLabel  matlab.ui.control.Label
        IGshapeonoveralltightnessEditFieldLabel  matlab.ui.control.Label
        IGscaleonoveralltightnessEditFieldLabel  matlab.ui.control.Label
        ar_panel                        matlab.ui.control.NumericEditField
        lambda1_panel                   matlab.ui.control.NumericEditField
        lambda2_panel                   matlab.ui.control.NumericEditField
        lambda3_panel                   matlab.ui.control.NumericEditField
        lambda4_panel                   matlab.ui.control.NumericEditField
        s0                              matlab.ui.control.NumericEditField
        v0                              matlab.ui.control.NumericEditField
        OptionsPanel_2                  matlab.ui.container.Panel
        TotalnumberofiterationsEditFieldLabel_2  matlab.ui.control.Label
        NumberofburniniterationsEditFieldLabel_2  matlab.ui.control.Label
        It_panel                        matlab.ui.control.NumericEditField
        Bu_panel                        matlab.ui.control.NumericEditField
        EnterlistofunitsPanel           matlab.ui.container.Panel
        unitnames                       matlab.ui.control.EditField
        HyperparametersPanel_3          matlab.ui.container.Panel
        IGshapeonresidualvarianceEditFieldLabel  matlab.ui.control.Label
        IGscaleonresidualvarianceEditFieldLabel  matlab.ui.control.Label
        ARcoefficientonresidualvarianceEditFieldLabel  matlab.ui.control.Label
        IGshapeonfactorvarianceEditFieldLabel  matlab.ui.control.Label
        IGscaleonfactorvarianceEditFieldLabel  matlab.ui.control.Label
        ARcoefficientonfactorEditFieldLabel  matlab.ui.control.Label
        VarianceonMetropolisdrawEditFieldLabel  matlab.ui.control.Label
        alpha0_panel                    matlab.ui.control.NumericEditField
        delta0_panel                    matlab.ui.control.NumericEditField
        gama_panel                      matlab.ui.control.NumericEditField
        a0                              matlab.ui.control.NumericEditField
        b0                              matlab.ui.control.NumericEditField
        rho                             matlab.ui.control.NumericEditField
        psi                             matlab.ui.control.NumericEditField
        ReplicationsPanel               matlab.ui.container.Panel
        RunEditField                    matlab.ui.control.EditField
        Label_2                         matlab.ui.control.Label
        Label_3                         matlab.ui.control.Label
        RunText                         matlab.ui.control.TextArea
    end

    
    %   methods (Access = public)
    %
    %         function results = interfaceinitial(apptest)
    %
    %             structInitial={'VARtype';'varendo';'varexo';'startdate';'enddate';
    %             'results';'plot';'datapath';'results_sub';'frequency';'constant';'lags'};
    %         varapp=size(structInitial);
    %         for i=1:varapp(1)
    %              app.(structInitial{i}).Value=apptest.(structInitial{i}).Value;
    %         end
    %         end
    %     end
    %
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %app.Interface_BEAR.Visible='off';
            %    clear;
            %addpath files
 %           app.Interface_BayesianVAR.Visible='on';
 %           app.BayesianVARPriorsOLSFAVARPanel.Visible='on';
 %           app.BayesianVARpriors.Enable='on';
 %           app.Interface_Applications.Visible='off';
 %           app.ReplicationsPanel.Visible='off';
 %           app.Interface_BEAR.Visible='off';
 %           app.Panel_Panel.Visible='off';
 %           app.OptionsPanel.Visible='off';
 %           app.StochasticVolatilityTimevaryingTrendsPanel.Visible='off';
 %           app.HyperparametersstochasticPanel.Visible='off';

   
            %load('files/appsettings.mat','appsettings');
            load('appsettings.mat','appsettings');
            %  Initial interface
            structInitial={'VARtype';'varendo';'varexo';'startdate';'enddate';
                'results';'plot';'datapath';'results_sub';'frequency';'constant';'lags'};
            varapp=size(structInitial);
            for i=1:varapp(1)
                app.(structInitial{i}).Value=appsettings.(structInitial{i}).Value;
            end
            %  BVARs
            structBVARs={'BayesianVARpriors'; 'FAVAR';'OLS';
                'ar'; 'lambda1'; 'lambda2'; 'lambda3'; 'lambda5'; 'lambda6'; 'lambda7'; 'lambda8'; 'priorexogenous';
                'It'; 'Bu'; 'hogs'; 'bex'; 'scoeff'; 'iobs'; 'lrp';'PriorExcel'};
            varapp=size(structBVARs);
            for i=1:varapp(1)
                app.(structBVARs{i}).Value=appsettings.(structBVARs{i}).Value;
            end
            
            %  TimeVARs
            structTVARs={'Standard'; 'RandomInertia'; 'LargeVAR'; 'VARcoefficientstime';'Generaltime';'Stochastictrend'; 'alpha0';
                'delta0'; 'gamma'; 'gamma0'; 'zeta0'; 'alltirf'};
            varapp=size(structTVARs);
            for i=1:varapp(1)
                app.(structTVARs{i}).Value=appsettings.(structTVARs{i}).Value;
            end
            
            % Panel
            structPVARs={'Meangroup'; 'RandomEffectZellnerHong';'StaticStructurefactor';'PooledEstimator';'RandomEffectHierarchical';'DynamicStructurefactor'
                'ar_panel';'lambda1_panel';'lambda2_panel';'lambda3_panel';'lambda4_panel';'s0';'v0';'It_panel';'Bu_panel';'unitnames';
                'alpha0_panel';'delta0_panel';'gama_panel';'a0';'b0';'rho';'psi'};
            varapp=size( structPVARs);
            for i=1:varapp(1)
                app.(structPVARs{i}).Value=appsettings.(structPVARs{i}).Value;
            end
            
            % FAVAR
            % transform to numbers
            structFAVARs={'transformation';'onestep';'slowfast';'blocks';'numpc';
                'transform_endo';'blocknames';'blocknumpc';'plotX';'plotXshock';
                'favarFEVDplot';'favarHDplot';'favarIRFplot'};
            for i=1:5
                app.(structFAVARs{i}).Value=num2str(appsettings.(structFAVARs{i}).Value);
            end
            for i=6:numel(structFAVARs)
                app.(structFAVARs{i}).Value=appsettings.(structFAVARs{i}).Value;
            end
            
            
            %  Applications
            structApplications={'IRF';'F'; 'HD'; 'CF'; 'FEVD'; 'Feval'; 'hstep';'window_size';
                'IRFperiods'; 'Fstartdate'; 'Fenddate'; 'Fendsmpl';
                'cband'; 'Instrument';  'startdateIV'; 'enddateIV'; 'prior_type_reduced_form';'prior_type_proxy';
                'evaluation_size'; 'Standardallshocks'; 'Standardshockspecific'; 'Tiltingmedian'; 'Tiltinginterval';
                'Noidentification'; 'Choleskifactorisation'; 'Triangularfactorisation'; 'Signrestrictions';'Proxy'; 'Proxysign'};
            %'Switchprobability';'Thin'
            varapp=size( structApplications);
            for i=1:5
                app.(structApplications{i}).Value=num2str(appsettings.(structApplications{i}).Value);
            end
            for i=6:varapp(1)
                app.(structApplications{i}).Value=appsettings.(structApplications{i}).Value;
            end
  %          app.Interface_Applications.Visible='off';
  %          app.ReplicationsPanel.Visible='off';
  %          app.Interface_BEAR.Visible='off';
            if app.FAVAR.Value==1
                app.FAVAROptions.Visible='on';
                app.FAVARplotPanel.Visible='on';
                app.favarIRFplot.Visible='on';
                app.favarFEVDplot.Visible='on';
                app.favarHDplot.Visible='on';
            else
                app.FAVAROptions.Visible='off';
                app.FAVARplotPanel.Visible='off';
                app.favarIRFplot.Visible='off';
                app.favarFEVDplot.Visible='off';
                app.favarHDplot.Visible='off';
            end
            if app.VARtype.Value(1:2)=='Ba'
                app.Interface_BayesianVAR.Visible='on';
                app.Panel_Panel.Visible='off';
                app.OptionsPanel.Visible='on';
                app.StochasticVolatilityTimevaryingTrendsPanel.Visible='off';
                app.BayesianVARPriorsOLSFAVARPanel.Visible='on';
                app.HyperparametersstochasticPanel.Visible='off';
                if app.OLS.Value==1
                app.BayesianVARpriors.Enable='off';
                app.VARtype.Visible='off';
                app.HyperparametersPanel.Visible='off';
                app.IterationsPanel.Visible='off';
                app.OptionsPanel.Visible='off';
                else
                    app.BayesianVARpriors.Enable='on';
                end
            end
            
            % Initialising commenting out
            
            if app.hogs.Value(1:2)=='Ye' app.lambda1.Enable=0; app.OveralltightnessEditFieldLabel.Enable=0;
                app.lambda2.Enable=0; app.CrossvariableweightingEditFieldLabel.Enable=0;
                app.lambda3.Enable=0; app.LagdecayEditFieldLabel.Enable=0;
                app.ar.Enable=0; app.AutoregressivecoefficientEditFieldLabel.Enable=0;
                app.PriorExcel.Enable=0;
            else app.lambda1.Enable=1; app.OveralltightnessEditFieldLabel.Enable=1;
                app.lambda2.Enable=1; app.CrossvariableweightingEditFieldLabel.Enable=1;
                app.lambda3.Enable=1; app.LagdecayEditFieldLabel.Enable=1;
                app.ar.Enable=1; app.AutoregressivecoefficientEditFieldLabel.Enable=1;
                app.PriorExcel.Enable=1;end
            
            if app.scoeff.Value==1 app.lambda6.Enable=1;app.SumofcoefficientstightnessEditFieldLabel.Enable=1;
            else app.lambda6.Enable=0; app.SumofcoefficientstightnessEditFieldLabel.Enable=0; end
            if app.lrp.Value==1 app.lambda8.Enable=1; app.LongrunpriortightnessEditFieldLabel.Enable=1;
            else app.lambda8.Enable=0; app.LongrunpriortightnessEditFieldLabel.Enable=0; end
            if app.iobs.Value==1 app.lambda7.Enable=1; app.DummyinitialobservationtightnessEditFieldLabel.Enable=1;
            else app.lambda7.Enable=0; app.DummyinitialobservationtightnessEditFieldLabel.Enable=0;end
            if app.bex.Value(1:2)=='Ye' app.lambda5.Enable=1; app.BlockexogeneityshrinkageEditFieldLabel.Enable=1;
            else app.lambda5.Enable=0; app.BlockexogeneityshrinkageEditFieldLabel.Enable=0; end
            
            %     if app.FEVD.Value=1 app.ProxyVars.Visible='off'; app.Proxy.Enable='off'; app.Proxysign.Enable='off';
            %     else app.ProxyVars.Visible='on'; app.Proxy.Enable='on'; app.Proxysign.Enable='on'; end
            
            
            if app.VARtype.Value(1:2)=='Pa' app.Interface_BayesianVAR.Visible='off'; app.Panel_Panel.Visible='on'; end;
            if app.VARtype.Value(1:2)=='Ti' app.Interface_BayesianVAR.Visible='on'; app.Panel_Panel.Visible='off';app.OptionsPanel.Visible='off';
                app.StochasticVolatilityTimevaryingTrendsPanel.Visible='on'; app.BayesianVARPriorsOLSFAVARPanel.Visible='off'; app.FAVAROptions.Visible='off';
                app.HyperparametersstochasticPanel.Visible='on';
            if app.Stochastictrend.Value==1 | app.VARcoefficientstime.Value==1 app.HyperparametersstochasticPanel.Visible='off';
            else app.HyperparametersstochasticPanel.Visible='on';
            end
    
            if app.Standard.Value==1 | app.LargeVAR.Value==1 | app.Generaltime.Value==1 app.gamma0.Enable='off'; app.Priormeanoninertia.Enable='off';
            app.zeta0.Enable='off'; app.Priorvarianceoninertia.Enable='off';
            else app.gamma0.Enable='on';app.Priormeanoninertia.Enable='on';
            app.zeta0.Enable='on'; app.Priorvarianceoninertia.Enable='on';
            end
        
            if app.RandomInertia.Value==1 app.gamma.Enable='off'; app.ARcoefficientonresidualvariance.Enable='off';
            else app.gamma.Enable='on';app.ARcoefficientonresidualvariance.Enable='on';
            end
            
            if app.VARcoefficientstime.Value==1 | app.Generaltime.Value==1 app.HyperparametersPanel.Visible='off';
            else app.HyperparametersPanel.Visible='on';end
    
            end
        end

        % Menu selected function: SPECIFICATION
        function SPECIFICATIONMenuSelected(app, event)
            app.Interface_BEAR.Visible='off';
            app.Interface_Applications.Visible='off';
            app.Interface_Initialisation.Visible='on';
            app.ProxyVars.Visible='off';
            if app.VARtype.Value(1:2)=='Ba'
                app.Interface_BayesianVAR.Visible='on';
                app.Panel_Panel.Visible='off';
                app.OptionsPanel.Visible='on';
                app.StochasticVolatilityTimevaryingTrendsPanel.Visible='off';
                app.BayesianVARPriorsOLSFAVARPanel.Visible='on';
                app.HyperparametersstochasticPanel.Visible='off';
                if app.FAVAR.Value==1
                    app.FAVAROptions.Visible='on';
                else
                    app.FAVAROptions.Visible='off';
                end
                if app.OLS.Value==1
                    app.BayesianVARpriors.Enable='off';
                else
                    app.BayesianVARpriors.Enable='on';
                end
            end
            if app.VARtype.Value(1:2)=='Pa' app.Interface_BayesianVAR.Visible='off'; app.Panel_Panel.Visible='on';   end
            if app.VARtype.Value(1:2)=='Ti' app.Interface_BayesianVAR.Visible='on'; app.Panel_Panel.Visible='off';app.OptionsPanel.Visible='off';
                app.StochasticVolatilityTimevaryingTrendsPanel.Visible='on'; app.BayesianVARPriorsOLSFAVARPanel.Visible='off';
                app.HyperparametersstochasticPanel.Visible='on'; app.FAVAROptions.Visible='off'; end
            %      app.test = appspecification(app);
            app.ReplicationsPanel.Visible='off';
            app.datapath.Visible='on';
            app.SetpathtodataTextArea.Visible='on';
            app.VARtype.Visible='on';
            if app.OLS.Value==1 % special case
                app.VARtype.Visible='off';
                app.OptionsPanel.Visible='off';
            end
            
        end

        % Menu selected function: APPLICATIONS
        function APPLICATIONSMenuSelected(app, event)
            %  app.test = appapplication(app);
            app.Interface_Initialisation.Visible='on';
            app.Interface_BayesianVAR.Visible='off';
            app.Panel_Panel.Visible='off';
            app.Interface_Applications.Visible='on';
            app.ProxyVars.Visible='on';
            app.Interface_BEAR.Visible='off';
            if app.VARtype.Value(1:2)=='Ba' & app.BayesianVARpriors.Value(1:7)=="NormalW" & app.FAVAR.Value==0
                app.ProxyVars.Visible='on';
                app.Proxy.Enable='on';
                app.Proxysign.Enable='on';
            else
                app.ProxyVars.Visible='off';
                app.Proxy.Enable='off';
                app.Proxysign.Enable='off';
            end
            if app.OLS.Value==1
                app.ProxyVars.Visible='off';
                app.Proxy.Enable='off';
                app.Proxysign.Enable='off';
            end
            app.ReplicationsPanel.Visible='off';
            app.datapath.Visible='on';
            app.SetpathtodataTextArea.Visible='on';
            app.VARtype.Visible='on';
            if app.OLS.Value==1 % special case
                app.VARtype.Visible='off';
            end
        end

        % Menu selected function: BEARMenu
        function BEARMenuSelected(app, event)
            app.Interface_Initialisation.Visible='off';
            app.Interface_BayesianVAR.Visible='off';
            app.Interface_Applications.Visible='off';
            app.Interface_BEAR.Visible='on';
            app.ReplicationsPanel.Visible='off';
            app.datapath.Visible='on';
            app.SetpathtodataTextArea.Visible='on';
            app.VARtype.Visible='on';
            if app.OLS.Value==1 % special case
                app.VARtype.Visible='off';
            end
        end

        % Callback function
        function INITIALISATIONMenuSelected(app, event)
            app.Interface_Initialisation.Visible='on';
            app.Interface_Applications.Visible='off';
            app.Interface_BayesianVAR.Visible='on';
            app.ProxyVars.Visible='off';
            app.Interface_BEAR.Visible='off';
            app.ReplicationsPanel.Visible='off';
            app.datapath.Visible='on';
            app.SetpathtodataTextArea.Visible='on';
            app.VARtype.Visible='on';
        end

        % Value changed function: CF
        function CFValueChanged(app, event)
            if app.CF.Value=='0';
                app.Standardallshocks.Enable='off';
                app.Standardshockspecific.Enable='off';
                app.Tiltingmedian.Enable='off';
                app.Tiltinginterval.Enable='off';
            else
                app.Standardallshocks.Enable='on';
                app.Standardshockspecific.Enable='on';
                app.Tiltingmedian.Enable='on';
                app.Tiltinginterval.Enable='on';
            end
            
        end

        % Button pushed function: RUNButton
        function RUNButtonPushed(app, event)
            if app.ReplicationsPanel.Visible=='off' % the routine when settings are specified in the Interface
                appsettings.VARtype.Value=app.VARtype.Value;
                %  Initial interface
                structInitial={'VARtype';'varendo';'varexo';'startdate';'enddate';
                    'results';'plot';'datapath';'results_sub';'frequency';'constant';'lags'};
                varapp=size(structInitial);
                for i=1:varapp(1)
                    appsettings.(structInitial{i}).Value=app.(structInitial{i}).Value;
                end
                
                % Bayesian VAR
                structBVARs={'BayesianVARpriors'; 'FAVAR'; 'OLS';
                    'ar'; 'lambda1'; 'lambda2'; 'lambda3'; 'lambda5'; 'lambda6'; 'lambda7'; 'lambda8'; 'priorexogenous';
                    'It'; 'Bu'; 'hogs'; 'bex'; 'scoeff'; 'iobs'; 'lrp';'PriorExcel'};
                varapp=size( structBVARs);
                for i=1:varapp(1)
                    appsettings.(structBVARs{i}).Value=app.(structBVARs{i}).Value;
                end
                
                % Timevarying VAR
                structTVARs={'Standard'; 'RandomInertia'; 'LargeVAR'; 'VARcoefficientstime'; 'Generaltime';'Stochastictrend';'alpha0';
                    'delta0'; 'gamma'; 'gamma0'; 'zeta0';'alltirf'};
                varapp=size( structTVARs);
                for i=1:varapp(1)
                    appsettings.(structTVARs{i}).Value=app.(structTVARs{i}).Value;
                end
                
                % Panel
                structPVARs={'Meangroup'; 'RandomEffectZellnerHong';'StaticStructurefactor';'PooledEstimator';'RandomEffectHierarchical';'DynamicStructurefactor'
                    'ar_panel';'lambda1_panel';'lambda2_panel';'lambda3_panel';'lambda4_panel';'s0';'v0';'It_panel';'Bu_panel';'unitnames';
                    'alpha0_panel';'delta0_panel';'gama_panel';'a0';'b0';'rho';'psi'};
                varapp=size( structPVARs);
                for i=1:varapp(1)
                    appsettings.(structPVARs{i}).Value=app.(structPVARs{i}).Value;
                end
                
                % FAVAR
                % transform to numbers
                structFAVARs1={'transformation';'onestep';'slowfast';'blocks';'numpc'};
                %transform to strings
                structFAVARs2={'transform_endo';'blocknames';'blocknumpc';'plotX';'plotXshock'};
                %do not transform
                structFAVARs3={'favarFEVDplot';'favarHDplot';'favarIRFplot'};
                for i=1:numel(structFAVARs1) % these need to be tansformed to numbers
                    appsettings.(structFAVARs1{i}).Value=str2num(app.(structFAVARs1{i}).Value);
                end
                for i=1:numel(structFAVARs2)
                    %                 appsettings.(structFAVARs2{i}).Value=convertCharsToStrings(app.(structFAVARs2{i}).Value);
                    appsettings.(structFAVARs2{i}).Value=app.(structFAVARs2{i}).Value;
                end
                for i=1:numel(structFAVARs3)
                    appsettings.(structFAVARs3{i}).Value=app.(structFAVARs3{i}).Value;
                end
                
                % Applications
                structApplications={'IRF';'F'; 'HD'; 'CF'; 'FEVD'; 'Feval'; 'hstep';'window_size';
                    'IRFperiods'; 'Fstartdate'; 'Fenddate'; 'Fendsmpl';
                    'cband'; 'Instrument'; 'startdateIV'; 'enddateIV'; 'prior_type_reduced_form';'prior_type_proxy';
                    'evaluation_size'; 'Standardallshocks'; 'Standardshockspecific'; 'Tiltingmedian'; 'Tiltinginterval';
                    'Noidentification';'Choleskifactorisation';'Triangularfactorisation';'Signrestrictions';'Proxy';'Proxysign'};
                % 'Switchprobability'; 'Thin';
                varapp=size( structApplications);
                for i=1:5
                    appsettings.(structApplications{i}).Value=str2num(app.(structApplications{i}).Value);
                end
                for i=6:varapp(1)
                    appsettings.(structApplications{i}).Value=app.(structApplications{i}).Value;
                end
                
                save('appsettings.mat','appsettings');
                delete(app);
                
                %run bear_appsettings.m;
                %run bear_toolbox_main_code;
            elseif app.ReplicationsPanel.Visible=='on' % else if a pre-specified file is run from the replications tab/folder
                Run=app.RunEditField.Value;
                delete(app);
                %% load data and settings
                %BEAR path
                cd ..\ % one folder up
                BEARpath=pwd;
                filespath=[BEARpath filesep 'files' filesep];
                % save them
                checkRun.BEARpath=BEARpath;
                checkRun.filespath=filespath;
                
                % data file name
                dataxlsx=['data_',Run,'.xlsx'];
                % settings file name
                settingsm=['bear_settings_',Run,'.m'];
                
                % the data file path and the settings file path
                replicationpath=[BEARpath filesep 'replications' filesep];
                datapath1=[replicationpath dataxlsx];
                settingspath=[replicationpath settingsm];
                
                % replace the previous datafile with the one for the replication
                % but first save the previous one
                copyfile([BEARpath filesep 'data.xlsx'],[filespath 'data_previous.xlsx']);
                copyfile(datapath1,[BEARpath filesep 'data.xlsx']);
                
                % replace the previous BEAR settings file with the one for the replication
                % but first save the previous one
                copyfile([filespath 'bear_settings.m'],[filespath  'bear_settings_previous.m']);
                copyfile(settingspath,[filespath 'bear_settings.m']);
                
                % create this one to let BEAR check if we started it via this Run file
                checkRun.checkRun1=datetime;
                save([filespath 'checkRun'],'checkRun');
                
                % change again the directory here for consistency with other code
                cd files
                assignin('base','runapp',0);
                % load the settings directly
                %run('bear_settings');
                % run main code
                %run('bear_toolbox_main_code');
                
            end
        end

        % Value changed function: PriorExcel
        function PriorExcelValueChanged(app, event)
            value = app.PriorExcel.Value;
            if value==1 app.ar.Enable=0;end
            if value==0 app.ar.Enable=1;end
            
        end

        % Callback function: HyperparametersstochasticPanel, VARtype
        function VARtypeValueChanged(app, event)
            value = app.VARtype.Value;
            if app.VARtype.Value(1:2)=='Ba'
                app.Interface_BayesianVAR.Visible='on';
                app.HyperparametersPanel.Visible='on';
                app.Panel_Panel.Visible='off';
                app.OptionsPanel.Visible='on';
                app.StochasticVolatilityTimevaryingTrendsPanel.Visible='off';
                app.BayesianVARPriorsOLSFAVARPanel.Visible='on';
                app.HyperparametersstochasticPanel.Visible='off';
                if app.FAVAR.Value==1
                    app.FAVAROptions.Visible='on';
                    app.FAVARplotPanel.Visible='on';
                else
                    app.FAVAROptions.Visible='off';
                    app.FAVARplotPanel.Visible='off';
                end
            end
            if app.VARtype.Value(1:2)=='Pa' app.Interface_BayesianVAR.Visible='off'; app.Panel_Panel.Visible='on'; end;
            if app.VARtype.Value(1:2)=='Ti' app.Interface_BayesianVAR.Visible='on'; app.Panel_Panel.Visible='off';app.OptionsPanel.Visible='off';
                app.StochasticVolatilityTimevaryingTrendsPanel.Visible='on'; app.BayesianVARPriorsOLSFAVARPanel.Visible='off';
                app.FAVAROptions.Visible='off';
                if app.Stochastictrend.Value==1 app.HyperparametersstochasticPanel.Visible='off';
                else app.HyperparametersstochasticPanel.Visible='on';end
                
            end
            
        end

        % Callback function
        function FILEOpenMenuSelected(app, event)
            %           webWindows = matlab.internal.webwindowmanager.instance.findAllWebwindows(); %#ok<NASGU>
            %  webWindows = matlab.internal.webwindowmanager.instance.windowList;
            %   for ii = 1:length(webWindows)
            %       webWindow = webWindows(ii);
            %       if strcmp( webWindow.Title, app.BEAR.Name )
            %           break
            %       end
            %   end
            % accesssettings(app)
            % startupFcn(app);
            %filemat = uigetfile('*.m');
            %delete(app)
            %run(filemat)
            % Properties2
            %          load('apptestzzz.mat','apptestzzz');
            %           structInitial={'VARtype';'varendo';'varexo';'startdate';'enddate';
            %          'results';'plot';'datapath';'results_sub';'frequency';'constant';'lags'};
            %     varapp=size(structInitial);
            %     for i=1:varapp(1)
            %          app.(structInitial{i}).Value=apptest.(structInitial{i}).Value;
            %     end
            %        webWindow.setAlwaysOnTop(true);
            %  webWindow.setAlwaysOnTop(false);
        end

        % Value changed function: scoeff
        function scoeffValueChanged(app, event)
            if app.scoeff.Value==1
                app.lambda6.Enable=1;
                app.SumofcoefficientstightnessEditFieldLabel.Enable=1;
            else
                app.lambda6.Enable=0;
                app.SumofcoefficientstightnessEditFieldLabel.Enable=0;
            end
        end

        % Value changed function: lrp
        function lrpValueChanged(app, event)
            if app.lrp.Value==1 app.lambda8.Enable=1; app.LongrunpriortightnessEditFieldLabel.Enable=1;
            else app.lambda8.Enable=0; app.LongrunpriortightnessEditFieldLabel.Enable=0; end
        end

        % Value changed function: iobs
        function iobsValueChanged(app, event)
            if app.iobs.Value==1 app.lambda7.Enable=1; app.DummyinitialobservationtightnessEditFieldLabel.Enable=1;
            else app.lambda7.Enable=0; app.DummyinitialobservationtightnessEditFieldLabel.Enable=0;end
        end

        % Value changed function: bex
        function bexValueChanged(app, event)
            if app.bex.Value(1:2)=='Ye' app.lambda5.Enable=1; app.BlockexogeneityshrinkageEditFieldLabel.Enable=1;
            else app.lambda5.Enable=0; app.BlockexogeneityshrinkageEditFieldLabel.Enable=0; end
        end

        % Value changed function: hogs
        function hogsValueChanged(app, event)
            value = app.hogs.Value;
            if value(1:2)=='Ye' app.lambda1.Enable=0; app.OveralltightnessEditFieldLabel.Enable=0;
                app.lambda2.Enable=0; app.CrossvariableweightingEditFieldLabel.Enable=0;
                app.lambda3.Enable=0; app.LagdecayEditFieldLabel.Enable=0;
                app.ar.Enable=0; app.AutoregressivecoefficientEditFieldLabel.Enable=0;
                app.PriorExcel.Enable=0;
            else app.lambda1.Enable=1; app.OveralltightnessEditFieldLabel.Enable=1;
                app.lambda2.Enable=1; app.CrossvariableweightingEditFieldLabel.Enable=1;
                app.lambda3.Enable=1; app.LagdecayEditFieldLabel.Enable=1;
                app.ar.Enable=1; app.AutoregressivecoefficientEditFieldLabel.Enable=1;
                app.PriorExcel.Enable=1;
            end
            
        end

        % Selection changed function: ButtonGroup_4
        function ButtonGroup_4SelectionChanged(app, event)
            selectedButton = app.ButtonGroup_4.SelectedObject;
            if app.Stochastictrend.Value==1 | app.VARcoefficientstime.Value==1 app.HyperparametersstochasticPanel.Visible='off';
            else app.HyperparametersstochasticPanel.Visible='on';
            end
    
            if app.Standard.Value==1 | app.LargeVAR.Value==1 | app.Generaltime.Value==1 app.gamma0.Enable='off'; app.Priormeanoninertia.Enable='off';
            app.zeta0.Enable='off'; app.Priorvarianceoninertia.Enable='off';
            else app.gamma0.Enable='on';app.Priormeanoninertia.Enable='on';
            app.zeta0.Enable='on'; app.Priorvarianceoninertia.Enable='on';
            end
        
            if app.RandomInertia.Value==1 app.gamma.Enable='off'; app.ARcoefficientonresidualvariance.Enable='off';
            else app.gamma.Enable='on';app.ARcoefficientonresidualvariance.Enable='on';
            end
            
            if app.VARcoefficientstime.Value==1 | app.Generaltime.Value==1 app.HyperparametersPanel.Visible='off';
            else app.HyperparametersPanel.Visible='on';end
          
        end

        % Value changed function: HD
        function HDValueChanged(app, event)
            
        end

        % Callback function: FAVAR, FAVARplotPanel
        function FAVARValueChanged(app, event)
            if app.FAVAR.Value==1
                app.FAVAROptions.Visible='on';
                app.FAVARplotPanel.Visible='on';
                app.favarIRFplot.Visible='on';
                app.favarFEVDplot.Visible='on';
                app.favarHDplot.Visible='on';
                
            else
                app.FAVAROptions.Visible='off';
                app.FAVARplotPanel.Visible='off';
                app.favarIRFplot.Visible='off';
                app.favarFEVDplot.Visible='off';
                app.favarHDplot.Visible='off';
            end
            
        end

        % Value changed function: OLS
        function OLSValueChanged(app, event)
            if app.OLS.Value==1
                app.BayesianVARpriors.Enable='off';
                app.VARtype.Visible='off';
                app.HyperparametersPanel.Visible='off';
                app.IterationsPanel.Visible='off';
                app.OptionsPanel.Visible='off';
            elseif app.OLS.Value==0
                app.BayesianVARpriors.Enable='on';
                app.VARtype.Visible='on';
                app.HyperparametersPanel.Visible='on';
                app.IterationsPanel.Visible='on';
                app.OptionsPanel.Visible='on';
            end
        end

        % Value changed function: FEVD
        function FEVDValueChanged(app, event)
            %    if app.FEVD.Value(1:2)=='Ye' app.ProxyVars.Visible='off'; app.Proxy.Enable='off'; app.Proxysign.Enable='off';
            %       else app.ProxyVars.Visible='on'; app.Proxy.Enable='on'; app.Proxysign.Enable='on';
            %       end
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            %selectedButton = app.ButtonGroup.SelectedObject;
            if app.Proxy.Value==1 | app.Proxysign.Value==1
                app.FEVD.Value='0';
                app.ProxyVars.Visible='on';
            else
                app.ProxyVars.Visible='off';
            end
%             if app.Proxy.Value==1
%                 
%             end
            
        end

        % Value changed function: BayesianVARpriors, plotX
        function BayesianVARpriorsValueChanged(app, event)
            value = app.BayesianVARpriors.Value;
            if value(1:2)=='No' | value(1:2)=='In' app.bex.Enable='off';
            else app.bex.Enable='on';end
        end

        % Close request function: BEAR
        function BEARCloseRequest(app, event)
            delete(app);
            runapp=0;
            assignin('base','runapp',runapp);
          %  ended bear
        end

        % Size changed function: Interface_BEAR
        function Interface_BEARSizeChanged(app, event)
            position = app.Interface_BEAR.Position;
            
        end

        % Value changing function: plotX
        function plotXValueChanging(app, event)
            changingValue = event.Value;
            app.plotX.Value=changingValue;
        end

        % Callback function
        function transformationValueChanged(app, event)
            %             value = app.transformation.Value;
            %             if value(1:2)=='No'
            %                 app.transformation.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.transformation.Value=1;
            %             end
        end

        % Callback function
        function blocksValueChanged(app, event)
            %             value = app.blocks.Value;
            %             if value(1:2)=='No'
            %                 app.blocks.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.blocks.Value=1;
            %             end
        end

        % Callback function
        function onestepValueChanged(app, event)
            %             value = app.onestep.Value;
            %             if value(1:2)=='No'
            %                 app.onestep.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.onestep.Value=1;
            %             end
        end

        % Callback function
        function slowfastValueChanged(app, event)
            %             value = app.slowfast.Value;
            %             if value(1:2)=='No'
            %                 app.slowfast.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.slowfast.Value=1;
            %             end
        end

        % Value changed function: favarIRFplot
        function favarIRFplotValueChanged(app, event)
            %             value = app.favarIRFplot.Value;
            %             if value(1:2)=='No'
            %                 app.favarIRFplot.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.favarIRFplot.Value=1;
            %             end
        end

        % Value changed function: favarFEVDplot
        function favarFEVDplotValueChanged(app, event)
            %             value = app.favarFEVDplot.Value;
            %             if value(1:2)=='No'
            %                 app.favarFEVDplot.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.favarFEVDplot.Value=1;
            %             end
        end

        % Value changed function: favarHDplot
        function favarHDplotValueChanged(app, event)
            %             value = app.favarHDplot.Value;
            %             if value(1:2)=='No'
            %                 app.favarHDplot.Value=0;
            %             elseif value(1:2)=='Yes'
            %                 app.favarHDplot.Value=1;
            %             end
        end

        % Menu selected function: REPLICATIONSMenu
        function REPLICATIONSMenuSelected(app, event)
            app.Interface_BEAR.Visible='off';
            app.Interface_BayesianVAR.Visible='off';
            app.Interface_Applications.Visible='off';
            app.Interface_Initialisation.Visible='off';
            app.ProxyVars.Visible='off';
            app.Panel_Panel.Visible='off';
            app.datapath.Visible='off';
            app.SetpathtodataTextArea.Visible='off';
            app.VARtype.Visible='off';
            app.ReplicationsPanel.Visible='on';
            
        end

        % Value changed function: RunEditField
        function RunEditFieldValueChanged(app, event)
           
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create BEAR and hide until all components are created
            app.BEAR = uifigure('Visible', 'off');
            app.BEAR.Color = [0.9412 0.9412 0.9412];
            app.BEAR.Position = [100 100 877 549];
            app.BEAR.Name = 'BEAR';
            app.BEAR.CloseRequestFcn = createCallbackFcn(app, @BEARCloseRequest, true);

            % Create REPLICATIONSMenu
            app.REPLICATIONSMenu = uimenu(app.BEAR);
            app.REPLICATIONSMenu.MenuSelectedFcn = createCallbackFcn(app, @REPLICATIONSMenuSelected, true);
            app.REPLICATIONSMenu.Text = 'REPLICATIONS       ';

            % Create SPECIFICATION
            app.SPECIFICATION = uimenu(app.BEAR);
            app.SPECIFICATION.MenuSelectedFcn = createCallbackFcn(app, @SPECIFICATIONMenuSelected, true);
            app.SPECIFICATION.ForegroundColor = [1 0.4118 0.1608];
            app.SPECIFICATION.Text = '           SPECIFICATION           ';

            % Create APPLICATIONS
            app.APPLICATIONS = uimenu(app.BEAR);
            app.APPLICATIONS.MenuSelectedFcn = createCallbackFcn(app, @APPLICATIONSMenuSelected, true);
            app.APPLICATIONS.ForegroundColor = [0.6392 0.0784 0.1804];
            app.APPLICATIONS.Text = '             APPLICATIONS          ';
            app.APPLICATIONS.HandleVisibility = 'off';

            % Create BEARMenu
            app.BEARMenu = uimenu(app.BEAR);
            app.BEARMenu.MenuSelectedFcn = createCallbackFcn(app, @BEARMenuSelected, true);
            app.BEARMenu.ForegroundColor = [1 0 0];
            app.BEARMenu.Text = '             BEAR     ';

            % Create RUNButton
            app.RUNButton = uibutton(app.BEAR, 'push');
            app.RUNButton.ButtonPushedFcn = createCallbackFcn(app, @RUNButtonPushed, true);
            app.RUNButton.Icon = 'bear-coloured1.png';
            app.RUNButton.BackgroundColor = [0.902 0.902 0.902];
            app.RUNButton.FontColor = [0.4706 0.6706 0.1882];
            app.RUNButton.Position = [187 512 114 36];
            app.RUNButton.Text = 'RUN';

            % Create VARtype
            app.VARtype = uidropdown(app.BEAR);
            app.VARtype.Items = {'Bayesian VAR', 'Time varying VAR', 'Panel VAR'};
            app.VARtype.ValueChangedFcn = createCallbackFcn(app, @VARtypeValueChanged, true);
            app.VARtype.FontSize = 16;
            app.VARtype.FontWeight = 'bold';
            app.VARtype.BackgroundColor = [0.902 0.902 0.902];
            app.VARtype.Position = [8 512 173 36];
            app.VARtype.Value = 'Bayesian VAR';

            % Create Interface_Initialisation
            app.Interface_Initialisation = uipanel(app.BEAR);
            app.Interface_Initialisation.Position = [9 32 292 475];

            % Create EnterthelistofendogenousvariablesLabel
            app.EnterthelistofendogenousvariablesLabel = uilabel(app.Interface_Initialisation);
            app.EnterthelistofendogenousvariablesLabel.Position = [8 350 207 22];
            app.EnterthelistofendogenousvariablesLabel.Text = 'Enter the list of endogenous variables';

            % Create varendo
            app.varendo = uitextarea(app.Interface_Initialisation);
            app.varendo.Position = [5 271 265 77];
            app.varendo.Value = {'Yer hicp stn'};

            % Create EnterthelistofexogenousvariablesLabel
            app.EnterthelistofexogenousvariablesLabel = uilabel(app.Interface_Initialisation);
            app.EnterthelistofexogenousvariablesLabel.Position = [10 244 200 22];
            app.EnterthelistofexogenousvariablesLabel.Text = 'Enter the list of exogenous variables';

            % Create varexo
            app.varexo = uitextarea(app.Interface_Initialisation);
            app.varexo.Position = [6 178 264 64];

            % Create EstimationStartdateLabel
            app.EstimationStartdateLabel = uilabel(app.Interface_Initialisation);
            app.EstimationStartdateLabel.HorizontalAlignment = 'right';
            app.EstimationStartdateLabel.Position = [4 412 117 22];
            app.EstimationStartdateLabel.Text = 'Estimation Start date';

            % Create startdate
            app.startdate = uieditfield(app.Interface_Initialisation, 'text');
            app.startdate.Position = [6 389 112 22];
            app.startdate.Value = '1999q1';

            % Create EstimationEnddateLabel
            app.EstimationEnddateLabel = uilabel(app.Interface_Initialisation);
            app.EstimationEnddateLabel.HorizontalAlignment = 'right';
            app.EstimationEnddateLabel.Position = [157 412 113 22];
            app.EstimationEnddateLabel.Text = 'Estimation End date';

            % Create enddate
            app.enddate = uieditfield(app.Interface_Initialisation, 'text');
            app.enddate.Position = [157 389 113 22];
            app.enddate.Value = '2018q4';

            % Create results
            app.results = uicheckbox(app.Interface_Initialisation);
            app.results.Text = 'Output in excel';
            app.results.Position = [10 104 102 22];
            app.results.Value = true;

            % Create plot
            app.plot = uicheckbox(app.Interface_Initialisation);
            app.plot.Text = 'Produce figures';
            app.plot.Position = [161 104 106 22];
            app.plot.Value = true;

            % Create SetresultsfileEditFieldLabel
            app.SetresultsfileEditFieldLabel = uilabel(app.Interface_Initialisation);
            app.SetresultsfileEditFieldLabel.HorizontalAlignment = 'right';
            app.SetresultsfileEditFieldLabel.Position = [4 68 81 22];
            app.SetresultsfileEditFieldLabel.Text = 'Set results file';

            % Create results_sub
            app.results_sub = uieditfield(app.Interface_Initialisation, 'text');
            app.results_sub.Position = [6 44 264 22];

            % Create DataFrequencyDropDownLabel
            app.DataFrequencyDropDownLabel = uilabel(app.Interface_Initialisation);
            app.DataFrequencyDropDownLabel.HorizontalAlignment = 'right';
            app.DataFrequencyDropDownLabel.Position = [1 446 91 22];
            app.DataFrequencyDropDownLabel.Text = 'Data Frequency';

            % Create frequency
            app.frequency = uidropdown(app.Interface_Initialisation);
            app.frequency.Items = {'Quarterly', 'Annual', 'Monthly', 'Daily', 'Undated'};
            app.frequency.Position = [104 444 166 22];
            app.frequency.Value = 'Quarterly';

            % Create IncludeconstantSwitchLabel
            app.IncludeconstantSwitchLabel = uilabel(app.Interface_Initialisation);
            app.IncludeconstantSwitchLabel.HorizontalAlignment = 'center';
            app.IncludeconstantSwitchLabel.Position = [98 141 93 22];
            app.IncludeconstantSwitchLabel.Text = 'Include constant';

            % Create constant
            app.constant = uiswitch(app.Interface_Initialisation, 'slider');
            app.constant.Position = [214 142 45 20];

            % Create LagsLabel
            app.LagsLabel = uilabel(app.Interface_Initialisation);
            app.LagsLabel.HorizontalAlignment = 'right';
            app.LagsLabel.Position = [5 141 31 22];
            app.LagsLabel.Text = 'Lags';

            % Create lags
            app.lags = uieditfield(app.Interface_Initialisation, 'numeric');
            app.lags.Position = [47 141 39 22];
            app.lags.Value = 1;

            % Create Interface_BEAR
            app.Interface_BEAR = uipanel(app.BEAR);
            app.Interface_BEAR.BorderType = 'none';
            app.Interface_BEAR.TitlePosition = 'centertop';
            app.Interface_BEAR.Title = 'By Alistair Dieppe and Bjorn van Roye';
            app.Interface_BEAR.Visible = 'off';
            app.Interface_BEAR.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Interface_BEAR.SizeChangedFcn = createCallbackFcn(app, @Interface_BEARSizeChanged, true);
            app.Interface_BEAR.FontAngle = 'italic';
            app.Interface_BEAR.FontWeight = 'bold';
            app.Interface_BEAR.FontSize = 16;
            app.Interface_BEAR.Position = [174 20 572 492];

            % Create BEARpicture
            app.BEARpicture = uibutton(app.Interface_BEAR, 'push');
            app.BEARpicture.Icon = 'bear-coloured1.png';
            app.BEARpicture.Position = [90 7 398 435];
            app.BEARpicture.Text = '';

            % Create Interface_Applications
            app.Interface_Applications = uipanel(app.BEAR);
            app.Interface_Applications.BorderType = 'none';
            app.Interface_Applications.Visible = 'off';
            app.Interface_Applications.Position = [307 0 572 513];

            % Create Applicationoptions
            app.Applicationoptions = uipanel(app.Interface_Applications);
            app.Applicationoptions.Title = 'Application options                               FAVAR';
            app.Applicationoptions.FontWeight = 'bold';
            app.Applicationoptions.Position = [6 340 267 166];

            % Create ImpulseresponsefunctionsSwitchLabel
            app.ImpulseresponsefunctionsSwitchLabel = uilabel(app.Applicationoptions);
            app.ImpulseresponsefunctionsSwitchLabel.Position = [4 116 155 22];
            app.ImpulseresponsefunctionsSwitchLabel.Text = 'Impulse response functions:';

            % Create IRF
            app.IRF = uiswitch(app.Applicationoptions, 'slider');
            app.IRF.Items = {'No', 'Yes'};
            app.IRF.ItemsData = {'0', '1'};
            app.IRF.Position = [178 120 28 12];
            app.IRF.Value = '1';

            % Create UnconditionalforecastsSwitchLabel
            app.UnconditionalforecastsSwitchLabel = uilabel(app.Applicationoptions);
            app.UnconditionalforecastsSwitchLabel.HorizontalAlignment = 'center';
            app.UnconditionalforecastsSwitchLabel.Position = [1 90 133 22];
            app.UnconditionalforecastsSwitchLabel.Text = 'Unconditional forecasts:';

            % Create F
            app.F = uiswitch(app.Applicationoptions, 'slider');
            app.F.Items = {'No', 'Yes'};
            app.F.ItemsData = {'0', '1'};
            app.F.Position = [177 95 28 12];
            app.F.Value = '1';

            % Create HistoricaldecompositionsSwitchLabel
            app.HistoricaldecompositionsSwitchLabel = uilabel(app.Applicationoptions);
            app.HistoricaldecompositionsSwitchLabel.HorizontalAlignment = 'center';
            app.HistoricaldecompositionsSwitchLabel.Position = [-2 36 148 22];
            app.HistoricaldecompositionsSwitchLabel.Text = ' Historical decompositions:';

            % Create HD
            app.HD = uiswitch(app.Applicationoptions, 'slider');
            app.HD.Items = {'No', 'Yes'};
            app.HD.ItemsData = {'0', '1'};
            app.HD.ValueChangedFcn = createCallbackFcn(app, @HDValueChanged, true);
            app.HD.Position = [177 41 28 12];
            app.HD.Value = '1';

            % Create ConditionalforecastsSwitchLabel
            app.ConditionalforecastsSwitchLabel = uilabel(app.Applicationoptions);
            app.ConditionalforecastsSwitchLabel.HorizontalAlignment = 'center';
            app.ConditionalforecastsSwitchLabel.Position = [-5 9 157 22];
            app.ConditionalforecastsSwitchLabel.Text = '  Conditional forecasts:         ';

            % Create CF
            app.CF = uiswitch(app.Applicationoptions, 'slider');
            app.CF.Items = {'No', 'Yes'};
            app.CF.ItemsData = {'0', '1'};
            app.CF.ValueChangedFcn = createCallbackFcn(app, @CFValueChanged, true);
            app.CF.Position = [177 12 28 12];
            app.CF.Value = '1';

            % Create ForecasterrorvarianceSwitchLabel
            app.ForecasterrorvarianceSwitchLabel = uilabel(app.Applicationoptions);
            app.ForecasterrorvarianceSwitchLabel.HorizontalAlignment = 'center';
            app.ForecasterrorvarianceSwitchLabel.Position = [1 62 136 22];
            app.ForecasterrorvarianceSwitchLabel.Text = 'Forecast error variance: ';

            % Create FEVD
            app.FEVD = uiswitch(app.Applicationoptions, 'slider');
            app.FEVD.Items = {'No', 'Yes'};
            app.FEVD.ItemsData = {'0', '1'};
            app.FEVD.ValueChangedFcn = createCallbackFcn(app, @FEVDValueChanged, true);
            app.FEVD.Position = [177 67 28 12];
            app.FEVD.Value = '0';

            % Create favarIRFplot
            app.favarIRFplot = uicheckbox(app.Applicationoptions);
            app.favarIRFplot.ValueChangedFcn = createCallbackFcn(app, @favarIRFplotValueChanged, true);
            app.favarIRFplot.Text = '';
            app.favarIRFplot.Position = [242 115 16 22];

            % Create favarFEVDplot
            app.favarFEVDplot = uicheckbox(app.Applicationoptions);
            app.favarFEVDplot.ValueChangedFcn = createCallbackFcn(app, @favarFEVDplotValueChanged, true);
            app.favarFEVDplot.Text = '';
            app.favarFEVDplot.Position = [242 62 16 22];

            % Create favarHDplot
            app.favarHDplot = uicheckbox(app.Applicationoptions);
            app.favarHDplot.ValueChangedFcn = createCallbackFcn(app, @favarHDplotValueChanged, true);
            app.favarHDplot.Text = '';
            app.favarHDplot.Position = [242 36 16 22];

            % Create Estimationoptions
            app.Estimationoptions = uipanel(app.Interface_Applications);
            app.Estimationoptions.Title = 'Estimation options:';
            app.Estimationoptions.FontWeight = 'bold';
            app.Estimationoptions.Position = [8 91 267 137];

            % Create ForecastevaluationsSwitchLabel
            app.ForecastevaluationsSwitchLabel = uilabel(app.Estimationoptions);
            app.ForecastevaluationsSwitchLabel.HorizontalAlignment = 'center';
            app.ForecastevaluationsSwitchLabel.Position = [3 87 119 22];
            app.ForecastevaluationsSwitchLabel.Text = 'Forecast evaluations:';

            % Create Feval
            app.Feval = uiswitch(app.Estimationoptions, 'slider');
            app.Feval.Items = {'No', 'Yes'};
            app.Feval.Position = [185 92 28 12];
            app.Feval.Value = 'Yes';

            % Create ForecaststepaheadevaluationsEditFieldLabel
            app.ForecaststepaheadevaluationsEditFieldLabel = uilabel(app.Estimationoptions);
            app.ForecaststepaheadevaluationsEditFieldLabel.Position = [4 60 182 22];
            app.ForecaststepaheadevaluationsEditFieldLabel.Text = 'Forecast step ahead evaluations:';

            % Create hstep
            app.hstep = uieditfield(app.Estimationoptions, 'numeric');
            app.hstep.Position = [217 60 37 22];
            app.hstep.Value = 1;

            % Create RollingWindow0forfullsampleEditFieldLabel
            app.RollingWindow0forfullsampleEditFieldLabel = uilabel(app.Estimationoptions);
            app.RollingWindow0forfullsampleEditFieldLabel.Position = [2 35 184 22];
            app.RollingWindow0forfullsampleEditFieldLabel.Text = 'Rolling Window (0 for full sample)';

            % Create window_size
            app.window_size = uieditfield(app.Estimationoptions, 'numeric');
            app.window_size.Position = [217 33 37 22];

            % Create EvaluationSizeEditFieldLabel
            app.EvaluationSizeEditFieldLabel = uilabel(app.Estimationoptions);
            app.EvaluationSizeEditFieldLabel.Position = [4 11 88 22];
            app.EvaluationSizeEditFieldLabel.Text = 'Evaluation Size';

            % Create evaluation_size
            app.evaluation_size = uieditfield(app.Estimationoptions, 'numeric');
            app.evaluation_size.Position = [217 7 37 22];
            app.evaluation_size.Value = 0.5;

            % Create Periodoptions
            app.Periodoptions = uipanel(app.Interface_Applications);
            app.Periodoptions.Title = 'Period options';
            app.Periodoptions.FontWeight = 'bold';
            app.Periodoptions.Position = [281 340 279 166];

            % Create IRFperiodsEditFieldLabel
            app.IRFperiodsEditFieldLabel = uilabel(app.Periodoptions);
            app.IRFperiodsEditFieldLabel.Position = [4 114 71 22];
            app.IRFperiodsEditFieldLabel.Text = 'IRF periods:';

            % Create IRFperiods
            app.IRFperiods = uieditfield(app.Periodoptions, 'numeric');
            app.IRFperiods.Position = [232 114 37 22];
            app.IRFperiods.Value = 1;

            % Create ForecastsafterlastsampleperiodSwitchLabel
            app.ForecastsafterlastsampleperiodSwitchLabel = uilabel(app.Periodoptions);
            app.ForecastsafterlastsampleperiodSwitchLabel.HorizontalAlignment = 'center';
            app.ForecastsafterlastsampleperiodSwitchLabel.Position = [1 33 190 22];
            app.ForecastsafterlastsampleperiodSwitchLabel.Text = 'Forecasts after last sample period:';

            % Create Fendsmpl
            app.Fendsmpl = uiswitch(app.Periodoptions, 'slider');
            app.Fendsmpl.Items = {'No', 'Yes'};
            app.Fendsmpl.Position = [221 38 28 12];
            app.Fendsmpl.Value = 'Yes';

            % Create ForecastsStartdateEditFieldLabel
            app.ForecastsStartdateEditFieldLabel = uilabel(app.Periodoptions);
            app.ForecastsStartdateEditFieldLabel.HorizontalAlignment = 'right';
            app.ForecastsStartdateEditFieldLabel.Position = [-1 90 120 22];
            app.ForecastsStartdateEditFieldLabel.Text = 'Forecasts: Start date:';

            % Create Fstartdate
            app.Fstartdate = uieditfield(app.Periodoptions, 'text');
            app.Fstartdate.HorizontalAlignment = 'right';
            app.Fstartdate.Position = [207 90 62 22];

            % Create ForecastsEnddateLabel
            app.ForecastsEnddateLabel = uilabel(app.Periodoptions);
            app.ForecastsEnddateLabel.HorizontalAlignment = 'right';
            app.ForecastsEnddateLabel.Position = [-2 61 116 22];
            app.ForecastsEnddateLabel.Text = 'Forecasts: End date:';

            % Create Fenddate
            app.Fenddate = uieditfield(app.Periodoptions, 'text');
            app.Fenddate.HorizontalAlignment = 'right';
            app.Fenddate.Position = [207 61 62 22];

            % Create VARcoefficientsEditFieldLabel
            app.VARcoefficientsEditFieldLabel = uilabel(app.Periodoptions);
            app.VARcoefficientsEditFieldLabel.Position = [4 7 110 22];
            app.VARcoefficientsEditFieldLabel.Text = 'Credibility Intervals:';

            % Create cband
            app.cband = uieditfield(app.Periodoptions, 'numeric');
            app.cband.Position = [208 8 62 22];
            app.cband.Value = 0.95;

            % Create Structuralidentifications
            app.Structuralidentifications = uipanel(app.Interface_Applications);
            app.Structuralidentifications.Title = 'Structural identifications:';
            app.Structuralidentifications.FontWeight = 'bold';
            app.Structuralidentifications.Position = [281 235 280 100];

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.Structuralidentifications);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.BorderType = 'none';
            app.ButtonGroup.Position = [6 5 265 67];

            % Create Noidentification
            app.Noidentification = uiradiobutton(app.ButtonGroup);
            app.Noidentification.Text = 'None';
            app.Noidentification.Position = [1 48 58 22];
            app.Noidentification.Value = true;

            % Create Choleskifactorisation
            app.Choleskifactorisation = uiradiobutton(app.ButtonGroup);
            app.Choleskifactorisation.Text = 'Choleski';
            app.Choleskifactorisation.Position = [140 48 68 22];

            % Create Triangularfactorisation
            app.Triangularfactorisation = uiradiobutton(app.ButtonGroup);
            app.Triangularfactorisation.Text = 'Triangular';
            app.Triangularfactorisation.Position = [1 24 144 22];

            % Create Signrestrictions
            app.Signrestrictions = uiradiobutton(app.ButtonGroup);
            app.Signrestrictions.Text = 'Sign restrictions';
            app.Signrestrictions.Position = [141 25 107 22];

            % Create Proxy
            app.Proxy = uiradiobutton(app.ButtonGroup);
            app.Proxy.Text = 'Proxy SVAR';
            app.Proxy.Position = [1 0 88 22];

            % Create Proxysign
            app.Proxysign = uiradiobutton(app.ButtonGroup);
            app.Proxysign.Text = 'Sign and proxy';
            app.Proxysign.Position = [141 1 102 22];

            % Create TypesofconditionalforecastsButtongroup
            app.TypesofconditionalforecastsButtongroup = uibuttongroup(app.Interface_Applications);
            app.TypesofconditionalforecastsButtongroup.Title = 'Types of conditional forecasts';
            app.TypesofconditionalforecastsButtongroup.FontWeight = 'bold';
            app.TypesofconditionalforecastsButtongroup.Position = [9 235 265 100];

            % Create Standardallshocks
            app.Standardallshocks = uiradiobutton(app.TypesofconditionalforecastsButtongroup);
            app.Standardallshocks.Text = 'Standard (all shocks)';
            app.Standardallshocks.Position = [1 47 135 22];
            app.Standardallshocks.Value = true;

            % Create Standardshockspecific
            app.Standardshockspecific = uiradiobutton(app.TypesofconditionalforecastsButtongroup);
            app.Standardshockspecific.Text = 'Standard (shock specific)';
            app.Standardshockspecific.Position = [1 16 157 22];

            % Create Tiltingmedian
            app.Tiltingmedian = uiradiobutton(app.TypesofconditionalforecastsButtongroup);
            app.Tiltingmedian.Text = 'Titling (median)';
            app.Tiltingmedian.Position = [156 47 104 22];

            % Create Tiltinginterval
            app.Tiltinginterval = uiradiobutton(app.TypesofconditionalforecastsButtongroup);
            app.Tiltinginterval.Text = 'Titling (interval)';
            app.Tiltinginterval.Position = [156 16 103 22];

            % Create ProxyVars
            app.ProxyVars = uipanel(app.Interface_Applications);
            app.ProxyVars.Title = 'Proxy SVAR options';
            app.ProxyVars.Visible = 'off';
            app.ProxyVars.FontWeight = 'bold';
            app.ProxyVars.Position = [280 15 279 212];

            % Create InstrumentLabel
            app.InstrumentLabel = uilabel(app.ProxyVars);
            app.InstrumentLabel.Position = [6 160 65 22];
            app.InstrumentLabel.Text = 'Instrument:';

            % Create InstrumentstartdateLabel
            app.InstrumentstartdateLabel = uilabel(app.ProxyVars);
            app.InstrumentstartdateLabel.HorizontalAlignment = 'right';
            app.InstrumentstartdateLabel.Position = [1 134 124 22];
            app.InstrumentstartdateLabel.Text = 'Instrument: Start date:';

            % Create startdateIV
            app.startdateIV = uieditfield(app.ProxyVars, 'text');
            app.startdateIV.HorizontalAlignment = 'right';
            app.startdateIV.Position = [207 134 62 22];

            % Create InstrumentEnddateLabel
            app.InstrumentEnddateLabel = uilabel(app.ProxyVars);
            app.InstrumentEnddateLabel.HorizontalAlignment = 'right';
            app.InstrumentEnddateLabel.Position = [1 108 120 22];
            app.InstrumentEnddateLabel.Text = 'Instrument: End date:';

            % Create enddateIV
            app.enddateIV = uieditfield(app.ProxyVars, 'text');
            app.enddateIV.HorizontalAlignment = 'right';
            app.enddateIV.Position = [207 106 62 22];

            % Create Instrument
            app.Instrument = uieditfield(app.ProxyVars, 'text');
            app.Instrument.Position = [151 161 117 22];

            % Create FlatreducedformpriorLabel
            app.FlatreducedformpriorLabel = uilabel(app.ProxyVars);
            app.FlatreducedformpriorLabel.HorizontalAlignment = 'center';
            app.FlatreducedformpriorLabel.Position = [4 82 130 22];
            app.FlatreducedformpriorLabel.Text = 'Flat reduced form prior:';

            % Create prior_type_reduced_form
            app.prior_type_reduced_form = uiswitch(app.ProxyVars, 'slider');
            app.prior_type_reduced_form.Items = {'No', 'Yes'};
            app.prior_type_reduced_form.Position = [222 85 28 12];
            app.prior_type_reduced_form.Value = 'Yes';

            % Create HighrelevancepriorLabel
            app.HighrelevancepriorLabel = uilabel(app.ProxyVars);
            app.HighrelevancepriorLabel.HorizontalAlignment = 'center';
            app.HighrelevancepriorLabel.Position = [4 58 113 22];
            app.HighrelevancepriorLabel.Text = 'High relevance prior';

            % Create prior_type_proxy
            app.prior_type_proxy = uiswitch(app.ProxyVars, 'slider');
            app.prior_type_proxy.Items = {'No', 'Yes'};
            app.prior_type_proxy.Position = [222 63 28 12];
            app.prior_type_proxy.Value = 'Yes';

            % Create CorrelShockLabel
            app.CorrelShockLabel = uilabel(app.ProxyVars);
            app.CorrelShockLabel.Position = [8 32 75 22];
            app.CorrelShockLabel.Text = 'Correl Shock';

            % Create Correlshock
            app.Correlshock = uieditfield(app.ProxyVars, 'text');
            app.Correlshock.Position = [153 34 117 22];

            % Create CorrelInstrumentLabel
            app.CorrelInstrumentLabel = uilabel(app.ProxyVars);
            app.CorrelInstrumentLabel.Position = [8 8 98 22];
            app.CorrelInstrumentLabel.Text = 'Correl Instrument';

            % Create Correlinstrument
            app.Correlinstrument = uieditfield(app.ProxyVars, 'text');
            app.Correlinstrument.Position = [153 8 117 22];

            % Create FAVARplotPanel
            app.FAVARplotPanel = uipanel(app.Interface_Applications);
            app.FAVARplotPanel.Title = 'FAVAR plot';
            app.FAVARplotPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FAVARplotPanel.SizeChangedFcn = createCallbackFcn(app, @FAVARValueChanged, true);
            app.FAVARplotPanel.FontWeight = 'bold';
            app.FAVARplotPanel.Position = [9 13 265 73];

            % Create PlotXLabel
            app.PlotXLabel = uilabel(app.FAVARplotPanel);
            app.PlotXLabel.Position = [8 28 37 22];
            app.PlotXLabel.Text = 'Plot X';

            % Create plotX
            app.plotX = uieditfield(app.FAVARplotPanel, 'text');
            app.plotX.ValueChangedFcn = createCallbackFcn(app, @BayesianVARpriorsValueChanged, true);
            app.plotX.ValueChangingFcn = createCallbackFcn(app, @plotXValueChanging, true);
            app.plotX.Position = [137 26 117 22];

            % Create PlotXshockLabel
            app.PlotXshockLabel = uilabel(app.FAVARplotPanel);
            app.PlotXshockLabel.Position = [9 3 69 22];
            app.PlotXshockLabel.Text = 'PlotX shock';

            % Create plotXshock
            app.plotXshock = uieditfield(app.FAVARplotPanel, 'text');
            app.plotXshock.Position = [137 2 117 21];

            % Create Interface_BayesianVAR
            app.Interface_BayesianVAR = uipanel(app.BEAR);
            app.Interface_BayesianVAR.BorderType = 'none';
            app.Interface_BayesianVAR.Position = [310 12 558 495];

            % Create BayesianVARPriorsOLSFAVARPanel
            app.BayesianVARPriorsOLSFAVARPanel = uipanel(app.Interface_BayesianVAR);
            app.BayesianVARPriorsOLSFAVARPanel.Title = 'Bayesian VAR Priors                                                OLS                          FAVAR';
            app.BayesianVARPriorsOLSFAVARPanel.FontWeight = 'bold';
            app.BayesianVARPriorsOLSFAVARPanel.Position = [9 412 528 58];

            % Create BayesianVARpriors
            app.BayesianVARpriors = uidropdown(app.BayesianVARPriorsOLSFAVARPanel);
            app.BayesianVARpriors.Items = {'Minnesota', 'NormalDiffuse', 'Dummyobservations', 'NormalWishart', 'IndependentNormalWishart', 'Deterministic'};
            app.BayesianVARpriors.ValueChangedFcn = createCallbackFcn(app, @BayesianVARpriorsValueChanged, true);
            app.BayesianVARpriors.Position = [7 9 205 22];
            app.BayesianVARpriors.Value = 'Minnesota';

            % Create OLS
            app.OLS = uicheckbox(app.BayesianVARPriorsOLSFAVARPanel);
            app.OLS.ValueChangedFcn = createCallbackFcn(app, @OLSValueChanged, true);
            app.OLS.Text = 'OLS';
            app.OLS.Position = [284 7 46 22];

            % Create FAVAR
            app.FAVAR = uicheckbox(app.BayesianVARPriorsOLSFAVARPanel);
            app.FAVAR.ValueChangedFcn = createCallbackFcn(app, @FAVARValueChanged, true);
            app.FAVAR.Text = 'FAVAR';
            app.FAVAR.Position = [397 7 59 22];

            % Create HyperparametersPanel
            app.HyperparametersPanel = uipanel(app.Interface_BayesianVAR);
            app.HyperparametersPanel.Title = 'Hyperparameters';
            app.HyperparametersPanel.FontWeight = 'bold';
            app.HyperparametersPanel.Position = [8 23 260 343];

            % Create AutoregressivecoefficientEditFieldLabel
            app.AutoregressivecoefficientEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.AutoregressivecoefficientEditFieldLabel.HorizontalAlignment = 'right';
            app.AutoregressivecoefficientEditFieldLabel.Position = [3 290 142 22];
            app.AutoregressivecoefficientEditFieldLabel.Text = 'Autoregressive coefficient';

            % Create OveralltightnessEditFieldLabel
            app.OveralltightnessEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.OveralltightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.OveralltightnessEditFieldLabel.Position = [2 261 95 22];
            app.OveralltightnessEditFieldLabel.Text = 'Overall tightness';

            % Create CrossvariableweightingEditFieldLabel
            app.CrossvariableweightingEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.CrossvariableweightingEditFieldLabel.HorizontalAlignment = 'right';
            app.CrossvariableweightingEditFieldLabel.Position = [1 230 137 22];
            app.CrossvariableweightingEditFieldLabel.Text = 'Cross-variable weighting';

            % Create LagdecayEditFieldLabel
            app.LagdecayEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.LagdecayEditFieldLabel.HorizontalAlignment = 'right';
            app.LagdecayEditFieldLabel.Position = [2 199 61 22];
            app.LagdecayEditFieldLabel.Text = 'Lag decay';

            % Create BlockexogeneityshrinkageEditFieldLabel
            app.BlockexogeneityshrinkageEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.BlockexogeneityshrinkageEditFieldLabel.HorizontalAlignment = 'right';
            app.BlockexogeneityshrinkageEditFieldLabel.Enable = 'off';
            app.BlockexogeneityshrinkageEditFieldLabel.Position = [2 137 151 22];
            app.BlockexogeneityshrinkageEditFieldLabel.Text = 'Block exogeneity shrinkage';

            % Create SumofcoefficientstightnessEditFieldLabel
            app.SumofcoefficientstightnessEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.SumofcoefficientstightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.SumofcoefficientstightnessEditFieldLabel.Enable = 'off';
            app.SumofcoefficientstightnessEditFieldLabel.Position = [1 106 158 22];
            app.SumofcoefficientstightnessEditFieldLabel.Text = 'Sum of coefficients tightness';

            % Create DummyinitialobservationtightnessEditFieldLabel
            app.DummyinitialobservationtightnessEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.DummyinitialobservationtightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.DummyinitialobservationtightnessEditFieldLabel.Enable = 'off';
            app.DummyinitialobservationtightnessEditFieldLabel.Position = [1 75 195 22];
            app.DummyinitialobservationtightnessEditFieldLabel.Text = 'Dummy initial observation tightness';

            % Create LongrunpriortightnessEditFieldLabel
            app.LongrunpriortightnessEditFieldLabel = uilabel(app.HyperparametersPanel);
            app.LongrunpriortightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.LongrunpriortightnessEditFieldLabel.Enable = 'off';
            app.LongrunpriortightnessEditFieldLabel.Position = [2 45 132 22];
            app.LongrunpriortightnessEditFieldLabel.Text = 'Long-run prior tightness';

            % Create ExogenousvariablesSwitchLabel
            app.ExogenousvariablesSwitchLabel = uilabel(app.HyperparametersPanel);
            app.ExogenousvariablesSwitchLabel.HorizontalAlignment = 'center';
            app.ExogenousvariablesSwitchLabel.Position = [3 168 117 22];
            app.ExogenousvariablesSwitchLabel.Text = 'Exogenous variables';

            % Create priorexogenous
            app.priorexogenous = uiswitch(app.HyperparametersPanel, 'slider');
            app.priorexogenous.Items = {'Excel', 'Default'};
            app.priorexogenous.Position = [166 169 46 20];
            app.priorexogenous.Value = 'Excel';

            % Create lambda1
            app.lambda1 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda1.Position = [197 261 59 22];

            % Create lambda2
            app.lambda2 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda2.Position = [197 231 59 22];

            % Create lambda3
            app.lambda3 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda3.Position = [197 204 59 22];

            % Create lambda5
            app.lambda5 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda5.Enable = 'off';
            app.lambda5.Position = [196 139 59 22];

            % Create lambda6
            app.lambda6 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda6.Enable = 'off';
            app.lambda6.Position = [196 108 59 22];

            % Create lambda7
            app.lambda7 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda7.Enable = 'off';
            app.lambda7.Position = [197 79 59 22];

            % Create lambda8
            app.lambda8 = uieditfield(app.HyperparametersPanel, 'numeric');
            app.lambda8.Enable = 'off';
            app.lambda8.Position = [197 50 59 22];

            % Create ar
            app.ar = uieditfield(app.HyperparametersPanel, 'numeric');
            app.ar.Position = [198 287 59 22];

            % Create PriorExcel
            app.PriorExcel = uicheckbox(app.HyperparametersPanel);
            app.PriorExcel.ValueChangedFcn = createCallbackFcn(app, @PriorExcelValueChanged, true);
            app.PriorExcel.Text = 'Excel';
            app.PriorExcel.Position = [149 290 51 22];

            % Create OptionsPanel
            app.OptionsPanel = uipanel(app.Interface_BayesianVAR);
            app.OptionsPanel.Title = 'Options';
            app.OptionsPanel.FontWeight = 'bold';
            app.OptionsPanel.Position = [279 22 260 256];

            % Create GridsearchonexcelSwitchLabel
            app.GridsearchonexcelSwitchLabel = uilabel(app.OptionsPanel);
            app.GridsearchonexcelSwitchLabel.HorizontalAlignment = 'center';
            app.GridsearchonexcelSwitchLabel.Position = [8 203 123 22];
            app.GridsearchonexcelSwitchLabel.Text = 'Grid search (on excel)';

            % Create hogs
            app.hogs = uiswitch(app.OptionsPanel, 'slider');
            app.hogs.Items = {'No', 'Yes'};
            app.hogs.ValueChangedFcn = createCallbackFcn(app, @hogsValueChanged, true);
            app.hogs.Position = [184 204 46 20];
            app.hogs.Value = 'No';

            % Create BlockexogeneityonexcelSwitchLabel
            app.BlockexogeneityonexcelSwitchLabel = uilabel(app.OptionsPanel);
            app.BlockexogeneityonexcelSwitchLabel.HorizontalAlignment = 'center';
            app.BlockexogeneityonexcelSwitchLabel.Position = [7 172 152 22];
            app.BlockexogeneityonexcelSwitchLabel.Text = 'Block exogeneity (on excel)';

            % Create bex
            app.bex = uiswitch(app.OptionsPanel, 'slider');
            app.bex.Items = {'No', 'Yes'};
            app.bex.ValueChangedFcn = createCallbackFcn(app, @bexValueChanged, true);
            app.bex.Position = [184 173 46 20];
            app.bex.Value = 'No';

            % Create scoeff
            app.scoeff = uicheckbox(app.OptionsPanel);
            app.scoeff.ValueChangedFcn = createCallbackFcn(app, @scoeffValueChanged, true);
            app.scoeff.Text = 'Sum of coefficients';
            app.scoeff.Position = [8 111 123 22];

            % Create iobs
            app.iobs = uicheckbox(app.OptionsPanel);
            app.iobs.ValueChangedFcn = createCallbackFcn(app, @iobsValueChanged, true);
            app.iobs.Text = 'Dummy initial observations';
            app.iobs.Position = [8 77 165 22];

            % Create lrp
            app.lrp = uicheckbox(app.OptionsPanel);
            app.lrp.ValueChangedFcn = createCallbackFcn(app, @lrpValueChanged, true);
            app.lrp.Text = 'Long-run priors';
            app.lrp.Position = [8 44 103 22];

            % Create Dummyobservationextensions
            app.Dummyobservationextensions = uilabel(app.OptionsPanel);
            app.Dummyobservationextensions.Position = [10 143 173 22];
            app.Dummyobservationextensions.Text = 'Dummy observation extensions';

            % Create StochasticVolatilityTimevaryingTrendsPanel
            app.StochasticVolatilityTimevaryingTrendsPanel = uipanel(app.Interface_BayesianVAR);
            app.StochasticVolatilityTimevaryingTrendsPanel.Title = 'Stochastic Volatility                     Time-varying                        Trends';
            app.StochasticVolatilityTimevaryingTrendsPanel.Visible = 'off';
            app.StochasticVolatilityTimevaryingTrendsPanel.FontWeight = 'bold';
            app.StochasticVolatilityTimevaryingTrendsPanel.Position = [10 370 527 115];

            % Create ButtonGroup_4
            app.ButtonGroup_4 = uibuttongroup(app.StochasticVolatilityTimevaryingTrendsPanel);
            app.ButtonGroup_4.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroup_4SelectionChanged, true);
            app.ButtonGroup_4.BorderType = 'none';
            app.ButtonGroup_4.Position = [3 11 513 75];

            % Create Standard
            app.Standard = uiradiobutton(app.ButtonGroup_4);
            app.Standard.Text = 'Standard';
            app.Standard.Position = [11 49 71 22];
            app.Standard.Value = true;

            % Create RandomInertia
            app.RandomInertia = uiradiobutton(app.ButtonGroup_4);
            app.RandomInertia.Text = 'Random Inertia';
            app.RandomInertia.Position = [11 27 104 22];

            % Create LargeVAR
            app.LargeVAR = uiradiobutton(app.ButtonGroup_4);
            app.LargeVAR.Text = 'Large VAR';
            app.LargeVAR.Position = [11 5 80 22];

            % Create VARcoefficientstime
            app.VARcoefficientstime = uiradiobutton(app.ButtonGroup_4);
            app.VARcoefficientstime.Text = 'VAR coefficients';
            app.VARcoefficientstime.Position = [188 50 109 22];

            % Create Generaltime
            app.Generaltime = uiradiobutton(app.ButtonGroup_4);
            app.Generaltime.Text = 'General';
            app.Generaltime.Position = [188 28 65 22];

            % Create Stochastictrend
            app.Stochastictrend = uiradiobutton(app.ButtonGroup_4);
            app.Stochastictrend.Text = 'Stochastic';
            app.Stochastictrend.Position = [340 50 77 22];

            % Create IterationsPanel
            app.IterationsPanel = uipanel(app.Interface_BayesianVAR);
            app.IterationsPanel.Title = 'Iterations';
            app.IterationsPanel.FontWeight = 'bold';
            app.IterationsPanel.Position = [278 285 260 81];

            % Create TotalnumberofiterationsEditFieldLabel_3
            app.TotalnumberofiterationsEditFieldLabel_3 = uilabel(app.IterationsPanel);
            app.TotalnumberofiterationsEditFieldLabel_3.HorizontalAlignment = 'right';
            app.TotalnumberofiterationsEditFieldLabel_3.Position = [6 30 143 22];
            app.TotalnumberofiterationsEditFieldLabel_3.Text = 'Total number of iterations:';

            % Create NumberofburniniterationsEditFieldLabel_3
            app.NumberofburniniterationsEditFieldLabel_3 = uilabel(app.IterationsPanel);
            app.NumberofburniniterationsEditFieldLabel_3.HorizontalAlignment = 'right';
            app.NumberofburniniterationsEditFieldLabel_3.Position = [6 3 154 22];
            app.NumberofburniniterationsEditFieldLabel_3.Text = 'Number of burn-in iterations';

            % Create It
            app.It = uieditfield(app.IterationsPanel, 'numeric');
            app.It.Position = [194 30 59 22];

            % Create Bu
            app.Bu = uieditfield(app.IterationsPanel, 'numeric');
            app.Bu.Position = [195 4 59 22];

            % Create HyperparametersstochasticPanel
            app.HyperparametersstochasticPanel = uipanel(app.Interface_BayesianVAR);
            app.HyperparametersstochasticPanel.Title = 'Hyperparameters stochastic / time varying';
            app.HyperparametersstochasticPanel.Visible = 'off';
            app.HyperparametersstochasticPanel.SizeChangedFcn = createCallbackFcn(app, @VARtypeValueChanged, true);
            app.HyperparametersstochasticPanel.FontWeight = 'bold';
            app.HyperparametersstochasticPanel.Position = [278 27 260 250];

            % Create IGshapeonresidualvariance
            app.IGshapeonresidualvariance = uilabel(app.HyperparametersstochasticPanel);
            app.IGshapeonresidualvariance.HorizontalAlignment = 'right';
            app.IGshapeonresidualvariance.Position = [2 172 165 22];
            app.IGshapeonresidualvariance.Text = 'IG shape on residual variance';

            % Create IGscaleonresidualvariance
            app.IGscaleonresidualvariance = uilabel(app.HyperparametersstochasticPanel);
            app.IGscaleonresidualvariance.HorizontalAlignment = 'right';
            app.IGscaleonresidualvariance.Position = [1 146 160 22];
            app.IGscaleonresidualvariance.Text = 'IG scale on residual variance';

            % Create ARcoefficientonresidualvariance
            app.ARcoefficientonresidualvariance = uilabel(app.HyperparametersstochasticPanel);
            app.ARcoefficientonresidualvariance.HorizontalAlignment = 'right';
            app.ARcoefficientonresidualvariance.Position = [-1 196 191 22];
            app.ARcoefficientonresidualvariance.Text = 'AR coefficient on residual variance';

            % Create Priormeanoninertia
            app.Priormeanoninertia = uilabel(app.HyperparametersstochasticPanel);
            app.Priormeanoninertia.HorizontalAlignment = 'right';
            app.Priormeanoninertia.Position = [1 118 117 22];
            app.Priormeanoninertia.Text = 'Prior mean on inertia';

            % Create Priorvarianceoninertia
            app.Priorvarianceoninertia = uilabel(app.HyperparametersstochasticPanel);
            app.Priorvarianceoninertia.HorizontalAlignment = 'right';
            app.Priorvarianceoninertia.Position = [-1 92 132 22];
            app.Priorvarianceoninertia.Text = 'Prior variance on inertia';

            % Create alpha0
            app.alpha0 = uieditfield(app.HyperparametersstochasticPanel, 'numeric');
            app.alpha0.Position = [194 173 61 22];

            % Create gamma
            app.gamma = uieditfield(app.HyperparametersstochasticPanel, 'numeric');
            app.gamma.Position = [194 199 61 22];

            % Create delta0
            app.delta0 = uieditfield(app.HyperparametersstochasticPanel, 'numeric');
            app.delta0.Position = [194 146 62 22];

            % Create gamma0
            app.gamma0 = uieditfield(app.HyperparametersstochasticPanel, 'numeric');
            app.gamma0.Position = [194 118 61 22];

            % Create zeta0
            app.zeta0 = uieditfield(app.HyperparametersstochasticPanel, 'numeric');
            app.zeta0.Position = [194 91 61 22];

            % Create alltirf
            app.alltirf = uicheckbox(app.HyperparametersstochasticPanel);
            app.alltirf.Text = 'Time-varying IRFs';
            app.alltirf.Position = [8 63 143 29];
            app.alltirf.Value = true;

            % Create FAVAROptions
            app.FAVAROptions = uipanel(app.Interface_BayesianVAR);
            app.FAVAROptions.Title = 'FAVAR Options';
            app.FAVAROptions.Visible = 'off';
            app.FAVAROptions.FontWeight = 'bold';
            app.FAVAROptions.Position = [276 23 260 256];

            % Create FAVARtransformationlabel
            app.FAVARtransformationlabel = uilabel(app.FAVAROptions);
            app.FAVARtransformationlabel.HorizontalAlignment = 'center';
            app.FAVARtransformationlabel.Position = [11 203 85 22];
            app.FAVARtransformationlabel.Text = 'Transformation';

            % Create onesteplabel
            app.onesteplabel = uilabel(app.FAVAROptions);
            app.onesteplabel.HorizontalAlignment = 'center';
            app.onesteplabel.Position = [15 144 51 22];
            app.onesteplabel.Text = 'Onestep';

            % Create transformation
            app.transformation = uiswitch(app.FAVAROptions, 'slider');
            app.transformation.Items = {'No', 'Yes'};
            app.transformation.ItemsData = {'0', '1'};
            app.transformation.Position = [184 204 46 20];
            app.transformation.Value = '1';

            % Create onestep
            app.onestep = uiswitch(app.FAVAROptions, 'slider');
            app.onestep.Items = {'No', 'Yes'};
            app.onestep.ItemsData = {'0', '1'};
            app.onestep.Position = [184 145 46 20];
            app.onestep.Value = '0';

            % Create TcodesendoLabel
            app.TcodesendoLabel = uilabel(app.FAVAROptions);
            app.TcodesendoLabel.HorizontalAlignment = 'right';
            app.TcodesendoLabel.Position = [30 173 74 22];
            app.TcodesendoLabel.Text = 'Tcodes endo';

            % Create transform_endo
            app.transform_endo = uieditfield(app.FAVAROptions, 'text');
            app.transform_endo.Position = [143 173 100 22];

            % Create slowfastlabel
            app.slowfastlabel = uilabel(app.FAVAROptions);
            app.slowfastlabel.HorizontalAlignment = 'center';
            app.slowfastlabel.Position = [14 118 49 22];
            app.slowfastlabel.Text = 'slowfast';

            % Create slowfast
            app.slowfast = uiswitch(app.FAVAROptions, 'slider');
            app.slowfast.Items = {'No', 'Yes'};
            app.slowfast.ItemsData = {'0', '1'};
            app.slowfast.Position = [184 119 46 20];
            app.slowfast.Value = '0';

            % Create blockslabel
            app.blockslabel = uilabel(app.FAVAROptions);
            app.blockslabel.HorizontalAlignment = 'center';
            app.blockslabel.Position = [16 92 41 22];
            app.blockslabel.Text = 'Blocks';

            % Create blocks
            app.blocks = uiswitch(app.FAVAROptions, 'slider');
            app.blocks.Items = {'No', 'Yes'};
            app.blocks.ItemsData = {'0', '1'};
            app.blocks.Position = [184 93 46 20];
            app.blocks.Value = '0';

            % Create BlocknamesLabel
            app.BlocknamesLabel = uilabel(app.FAVAROptions);
            app.BlocknamesLabel.HorizontalAlignment = 'right';
            app.BlocknamesLabel.Position = [11 40 74 22];
            app.BlocknamesLabel.Text = 'Block names';

            % Create blocknames
            app.blocknames = uieditfield(app.FAVAROptions, 'text');
            app.blocknames.Position = [150 40 100 22];

            % Create BlocknofactorsLabel
            app.BlocknofactorsLabel = uilabel(app.FAVAROptions);
            app.BlocknofactorsLabel.HorizontalAlignment = 'right';
            app.BlocknofactorsLabel.Position = [9 13 94 22];
            app.BlocknofactorsLabel.Text = 'Block no. factors';

            % Create blocknumpc
            app.blocknumpc = uieditfield(app.FAVAROptions, 'text');
            app.blocknumpc.Position = [149 13 100 22];

            % Create NofactorsLabel
            app.NofactorsLabel = uilabel(app.FAVAROptions);
            app.NofactorsLabel.HorizontalAlignment = 'right';
            app.NofactorsLabel.Position = [10 68 64 22];
            app.NofactorsLabel.Text = 'No. factors';

            % Create numpc
            app.numpc = uieditfield(app.FAVAROptions, 'text');
            app.numpc.Position = [150 68 100 22];

            % Create SetpathtodataTextArea
            app.SetpathtodataTextArea = uilabel(app.BEAR);
            app.SetpathtodataTextArea.Position = [307 519 90 22];
            app.SetpathtodataTextArea.Text = 'Set path to data';

            % Create datapath
            app.datapath = uitextarea(app.BEAR);
            app.datapath.Position = [402 520 444 21];

            % Create Panel_Panel
            app.Panel_Panel = uipanel(app.BEAR);
            app.Panel_Panel.BorderType = 'none';
            app.Panel_Panel.Visible = 'off';
            app.Panel_Panel.Position = [310 0 544 500];

            % Create BayesianPanelVARsPriors
            app.BayesianPanelVARsPriors = uipanel(app.Panel_Panel);
            app.BayesianPanelVARsPriors.Title = 'Bayesian Panel VARs Priors';
            app.BayesianPanelVARsPriors.FontWeight = 'bold';
            app.BayesianPanelVARsPriors.Position = [5 380 531 115];

            % Create ButtonGroup_3
            app.ButtonGroup_3 = uibuttongroup(app.BayesianPanelVARsPriors);
            app.ButtonGroup_3.BorderType = 'none';
            app.ButtonGroup_3.Position = [8 11 508 75];

            % Create Meangroup
            app.Meangroup = uiradiobutton(app.ButtonGroup_3);
            app.Meangroup.Text = ' Mean group Estimator';
            app.Meangroup.Position = [11 49 143 22];
            app.Meangroup.Value = true;

            % Create RandomEffectZellnerHong
            app.RandomEffectZellnerHong = uiradiobutton(app.ButtonGroup_3);
            app.RandomEffectZellnerHong.Text = 'Random Effect (Zellner-Hong)';
            app.RandomEffectZellnerHong.Position = [11 27 182 22];

            % Create StaticStructurefactor
            app.StaticStructurefactor = uiradiobutton(app.ButtonGroup_3);
            app.StaticStructurefactor.Text = 'Static Structure factor';
            app.StaticStructurefactor.Position = [11 5 137 22];

            % Create PooledEstimator
            app.PooledEstimator = uiradiobutton(app.ButtonGroup_3);
            app.PooledEstimator.Text = 'Pooled Estimator';
            app.PooledEstimator.Position = [276 50 113 22];

            % Create RandomEffectHierarchical
            app.RandomEffectHierarchical = uiradiobutton(app.ButtonGroup_3);
            app.RandomEffectHierarchical.Text = 'Random Effect (Hierarchical)';
            app.RandomEffectHierarchical.Position = [276 28 176 22];

            % Create DynamicStructurefactor
            app.DynamicStructurefactor = uiradiobutton(app.ButtonGroup_3);
            app.DynamicStructurefactor.Text = 'Dynamic Structure factor';
            app.DynamicStructurefactor.Position = [277 5 154 22];

            % Create HyperparametersPanel_panel
            app.HyperparametersPanel_panel = uipanel(app.Panel_Panel);
            app.HyperparametersPanel_panel.Title = 'Hyperparameters';
            app.HyperparametersPanel_panel.FontWeight = 'bold';
            app.HyperparametersPanel_panel.Position = [7 2 260 270];

            % Create AutoregressivecoefficientEditFieldLabel_2
            app.AutoregressivecoefficientEditFieldLabel_2 = uilabel(app.HyperparametersPanel_panel);
            app.AutoregressivecoefficientEditFieldLabel_2.HorizontalAlignment = 'right';
            app.AutoregressivecoefficientEditFieldLabel_2.Position = [3 219 142 22];
            app.AutoregressivecoefficientEditFieldLabel_2.Text = 'Autoregressive coefficient';

            % Create OveralltightnessEditFieldLabel_2
            app.OveralltightnessEditFieldLabel_2 = uilabel(app.HyperparametersPanel_panel);
            app.OveralltightnessEditFieldLabel_2.HorizontalAlignment = 'right';
            app.OveralltightnessEditFieldLabel_2.Position = [2 188 95 22];
            app.OveralltightnessEditFieldLabel_2.Text = 'Overall tightness';

            % Create CrossvariableweightingEditFieldLabel_2
            app.CrossvariableweightingEditFieldLabel_2 = uilabel(app.HyperparametersPanel_panel);
            app.CrossvariableweightingEditFieldLabel_2.HorizontalAlignment = 'right';
            app.CrossvariableweightingEditFieldLabel_2.Position = [1 157 137 22];
            app.CrossvariableweightingEditFieldLabel_2.Text = 'Cross-variable weighting';

            % Create LagdecayEditFieldLabel_2
            app.LagdecayEditFieldLabel_2 = uilabel(app.HyperparametersPanel_panel);
            app.LagdecayEditFieldLabel_2.HorizontalAlignment = 'right';
            app.LagdecayEditFieldLabel_2.Position = [2 126 61 22];
            app.LagdecayEditFieldLabel_2.Text = 'Lag decay';

            % Create ExogenousvariabletightnessEditFieldLabel
            app.ExogenousvariabletightnessEditFieldLabel = uilabel(app.HyperparametersPanel_panel);
            app.ExogenousvariabletightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.ExogenousvariabletightnessEditFieldLabel.Position = [-1 95 162 22];
            app.ExogenousvariabletightnessEditFieldLabel.Text = 'Exogenous variable tightness';

            % Create IGshapeonoveralltightnessEditFieldLabel
            app.IGshapeonoveralltightnessEditFieldLabel = uilabel(app.HyperparametersPanel_panel);
            app.IGshapeonoveralltightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.IGshapeonoveralltightnessEditFieldLabel.Position = [-2 63 161 22];
            app.IGshapeonoveralltightnessEditFieldLabel.Text = 'IG shape on overall tightness';

            % Create IGscaleonoveralltightnessEditFieldLabel
            app.IGscaleonoveralltightnessEditFieldLabel = uilabel(app.HyperparametersPanel_panel);
            app.IGscaleonoveralltightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.IGscaleonoveralltightnessEditFieldLabel.Position = [-1 33 156 22];
            app.IGscaleonoveralltightnessEditFieldLabel.Text = 'IG scale on overall tightness';

            % Create ar_panel
            app.ar_panel = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.ar_panel.Position = [199 220 55 22];

            % Create lambda1_panel
            app.lambda1_panel = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.lambda1_panel.Position = [199 189 55 22];

            % Create lambda2_panel
            app.lambda2_panel = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.lambda2_panel.Position = [199 158 55 22];

            % Create lambda3_panel
            app.lambda3_panel = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.lambda3_panel.Position = [199 127 55 22];

            % Create lambda4_panel
            app.lambda4_panel = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.lambda4_panel.Position = [199 95 55 22];

            % Create s0
            app.s0 = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.s0.Position = [199 65 55 22];

            % Create v0
            app.v0 = uieditfield(app.HyperparametersPanel_panel, 'numeric');
            app.v0.Position = [200 35 55 22];

            % Create OptionsPanel_2
            app.OptionsPanel_2 = uipanel(app.Panel_Panel);
            app.OptionsPanel_2.Title = 'Options';
            app.OptionsPanel_2.FontWeight = 'bold';
            app.OptionsPanel_2.Position = [275 280 261 89];

            % Create TotalnumberofiterationsEditFieldLabel_2
            app.TotalnumberofiterationsEditFieldLabel_2 = uilabel(app.OptionsPanel_2);
            app.TotalnumberofiterationsEditFieldLabel_2.HorizontalAlignment = 'right';
            app.TotalnumberofiterationsEditFieldLabel_2.Position = [4 38 143 22];
            app.TotalnumberofiterationsEditFieldLabel_2.Text = 'Total number of iterations:';

            % Create NumberofburniniterationsEditFieldLabel_2
            app.NumberofburniniterationsEditFieldLabel_2 = uilabel(app.OptionsPanel_2);
            app.NumberofburniniterationsEditFieldLabel_2.HorizontalAlignment = 'right';
            app.NumberofburniniterationsEditFieldLabel_2.Position = [5 7 154 22];
            app.NumberofburniniterationsEditFieldLabel_2.Text = 'Number of burn-in iterations';

            % Create It_panel
            app.It_panel = uieditfield(app.OptionsPanel_2, 'numeric');
            app.It_panel.Position = [198 35 55 22];

            % Create Bu_panel
            app.Bu_panel = uieditfield(app.OptionsPanel_2, 'numeric');
            app.Bu_panel.Position = [198 7 55 22];

            % Create EnterlistofunitsPanel
            app.EnterlistofunitsPanel = uipanel(app.Panel_Panel);
            app.EnterlistofunitsPanel.Title = 'Enter list of units';
            app.EnterlistofunitsPanel.FontWeight = 'bold';
            app.EnterlistofunitsPanel.Position = [5 280 260 89];

            % Create unitnames
            app.unitnames = uieditfield(app.EnterlistofunitsPanel, 'text');
            app.unitnames.Position = [6 4 247 58];

            % Create HyperparametersPanel_3
            app.HyperparametersPanel_3 = uipanel(app.Panel_Panel);
            app.HyperparametersPanel_3.Title = 'Hyperparameters';
            app.HyperparametersPanel_3.FontWeight = 'bold';
            app.HyperparametersPanel_3.Position = [279 10 260 260];

            % Create IGshapeonresidualvarianceEditFieldLabel
            app.IGshapeonresidualvarianceEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.IGshapeonresidualvarianceEditFieldLabel.HorizontalAlignment = 'right';
            app.IGshapeonresidualvarianceEditFieldLabel.Position = [-1 209 165 22];
            app.IGshapeonresidualvarianceEditFieldLabel.Text = 'IG shape on residual variance';

            % Create IGscaleonresidualvarianceEditFieldLabel
            app.IGscaleonresidualvarianceEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.IGscaleonresidualvarianceEditFieldLabel.HorizontalAlignment = 'right';
            app.IGscaleonresidualvarianceEditFieldLabel.Position = [-1 178 160 22];
            app.IGscaleonresidualvarianceEditFieldLabel.Text = 'IG scale on residual variance';

            % Create ARcoefficientonresidualvarianceEditFieldLabel
            app.ARcoefficientonresidualvarianceEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.ARcoefficientonresidualvarianceEditFieldLabel.HorizontalAlignment = 'right';
            app.ARcoefficientonresidualvarianceEditFieldLabel.Position = [-1 147 191 22];
            app.ARcoefficientonresidualvarianceEditFieldLabel.Text = 'AR coefficient on residual variance';

            % Create IGshapeonfactorvarianceEditFieldLabel
            app.IGshapeonfactorvarianceEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.IGshapeonfactorvarianceEditFieldLabel.HorizontalAlignment = 'right';
            app.IGshapeonfactorvarianceEditFieldLabel.Position = [1 116 153 22];
            app.IGshapeonfactorvarianceEditFieldLabel.Text = 'IG shape on factor variance';

            % Create IGscaleonfactorvarianceEditFieldLabel
            app.IGscaleonfactorvarianceEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.IGscaleonfactorvarianceEditFieldLabel.HorizontalAlignment = 'right';
            app.IGscaleonfactorvarianceEditFieldLabel.Position = [1 85 148 22];
            app.IGscaleonfactorvarianceEditFieldLabel.Text = 'IG scale on factor variance';

            % Create ARcoefficientonfactorEditFieldLabel
            app.ARcoefficientonfactorEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.ARcoefficientonfactorEditFieldLabel.HorizontalAlignment = 'right';
            app.ARcoefficientonfactorEditFieldLabel.Position = [1 53 129 22];
            app.ARcoefficientonfactorEditFieldLabel.Text = 'AR coefficient on factor';

            % Create VarianceonMetropolisdrawEditFieldLabel
            app.VarianceonMetropolisdrawEditFieldLabel = uilabel(app.HyperparametersPanel_3);
            app.VarianceonMetropolisdrawEditFieldLabel.HorizontalAlignment = 'right';
            app.VarianceonMetropolisdrawEditFieldLabel.Position = [-1 23 156 22];
            app.VarianceonMetropolisdrawEditFieldLabel.Text = 'Variance on Metropolis draw';

            % Create alpha0_panel
            app.alpha0_panel = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.alpha0_panel.Position = [199 209 55 22];

            % Create delta0_panel
            app.delta0_panel = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.delta0_panel.Position = [200 179 55 22];

            % Create gama_panel
            app.gama_panel = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.gama_panel.Position = [200 149 55 22];

            % Create a0
            app.a0 = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.a0.Position = [199 119 55 22];

            % Create b0
            app.b0 = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.b0.Position = [200 87 55 22];

            % Create rho
            app.rho = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.rho.Position = [201 57 55 22];

            % Create psi
            app.psi = uieditfield(app.HyperparametersPanel_3, 'numeric');
            app.psi.Position = [202 27 55 22];

            % Create ReplicationsPanel
            app.ReplicationsPanel = uipanel(app.BEAR);
            app.ReplicationsPanel.BorderType = 'none';
            app.ReplicationsPanel.TitlePosition = 'centertop';
            app.ReplicationsPanel.Title = 'Replications';
            app.ReplicationsPanel.Visible = 'off';
            app.ReplicationsPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ReplicationsPanel.FontWeight = 'bold';
            app.ReplicationsPanel.Position = [1 1 858 495];

            % Create RunEditField
            app.RunEditField = uieditfield(app.ReplicationsPanel, 'text');
            app.RunEditField.ValueChangedFcn = createCallbackFcn(app, @RunEditFieldValueChanged, true);
            app.RunEditField.HorizontalAlignment = 'center';
            app.RunEditField.Position = [307 450 250 20];

            % Create Label_2
            app.Label_2 = uilabel(app.ReplicationsPanel);
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Position = [298 448 10 22];
            app.Label_2.Text = '#';

            % Create Label_3
            app.Label_3 = uilabel(app.ReplicationsPanel);
            app.Label_3.FontWeight = 'bold';
            app.Label_3.Position = [559 449 11 22];
            app.Label_3.Text = '#';

            % Create RunText
            app.RunText = uitextarea(app.ReplicationsPanel);
            app.RunText.Editable = 'off';
            app.RunText.BackgroundColor = [0.9412 0.9412 0.9412];
            app.RunText.Position = [48 20 773 399];
            app.RunText.Value = {'Run a pre-specified data and settings file from the "replications" folder by entering a Run-code. '; 'Naming convention: '; 'data_#Run#'; 'bear_settings_#Run# '; 'and copy both to the "replications" folder.'; ''; 'List of replications:'; '% ## '; 'if Run is empty a test sample will be run'; ''; '% #AAU2009# '; 'Amir Ahmadi & Uhlig (2009): Measuring the Dynamic Effects of Monetary Policy Shocks: A Bayesian FAVAR Approach with Sign Restriction'; ''; '% #BvV2018#'; 'Banbura & van Vlodrop (2018): Forecasting with Bayesian Vector Autoregressions with Time Variation in the Mean'; ''; '% #BBE2005#'; 'Bernanke & Boivin & Eliasz (2005): Measuring the effects of Monetary Policy: A factor Autoregressive (FAVAR) approach'; ''; '% #CH2019#'; 'Caldara & Herbst (2019): Monetary Policy Real Activity and Credit Spreads: Evidence from Bayesian Proxy SVARs'; ''; '% #WGP2016#'; 'Wieladek & Garcia Pascual (2016): The European Central Bank''s QE: A New Hope [extended]'};

            % Show the figure after all components are created
            app.BEAR.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = interface_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BEAR)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.BEAR)
        end
    end
end