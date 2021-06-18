classdef BVARSettings < bear.settings.BASELINESettings
    
    properties
        strctident
        
        % selected prior
        % 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
        % 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
        % 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
        % 41=Normal-diffuse
        % 51=Dummy observations
        % 61=Mean-adjusted
        prior=61;
        % hyperparameter: autoregressive coefficient
        ar=0.8; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
        % switch to Excel interface
        PriorExcel=0; % set to 1 if you want individual priors, 0 for default
        %switch to Excel interface for exogenous variables
        priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
        % hyperparameter: lambda1
        lambda1=10000;
        % hyperparameter: lambda2
        lambda2=0.5;
        % hyperparameter: lambda3
        lambda3=1;
        % hyperparameter: lambda4
        lambda4=1;
        % hyperparameter: lambda5
        lambda5=0.001;
        % hyperparameter: lambda6
        lambda6=1;
        % hyperparameter: lambda7
        lambda7=0.1;
        % Overall tightness on the long run prior
        lambda8=1;
        % total number of iterations for the Gibbs sampler
        It=1000;
        % number of burn-in iterations for the Gibbs sampler
        Bu=500;
        % hyperparameter optimisation by grid search (1=yes, 0=no)
        hogs=0;
        % block exogeneity (1=yes, 0=no)
        bex=0;
        % sum-of-coefficients application (1=yes, 0=no)
        scoeff=0;
        % dummy initial observation application (1=yes, 0=no)
        iobs=0;
        % Long run prior option
        lrp=0;
        % create H matrix for the long run priors
        % now taken from excel loadH.m
        % H=[1 1 0 0;-1 1 0 0;0 0 1 1;0 0 -1 1];
        % (61=Mean-adjusted BVAR) Scale up the variance of the prior of factor f
        priorf=100;
    end
    
    methods
        
        function obj = BVARSettings(excelPath, varargin)

            obj@bear.settings.BASELINESettings(2, excelPath)
            
            if obj.IRFt==4
                strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
                % Correlation restriction options:
                strctident.CorrelShock=''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
                strctident.CorrelInstrument=''; % provide the IV variable in excel sheet "IV"
            elseif obj.IRFt==5
                strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
                % IV options:
                strctident.Instrument='MHF'; % specify Instrument to identfy Shock
                strctident.startdateIV='1992m2';
                strctident.enddateIV='2003m12';
                strctident.Thin=10;
                strctident.prior_type_reduced_form=1; %1=flat (standard), 2=normal wishart , related to the IV routine
                strctident.Switchprobability=0; % (=0 standard) related to the IV routine, governs the believe of the researcher if the posterior distribution of Sigma|Y as specified by the standard inverse Wishart distribution, is a good proposal distribution for Sigma|Y, IV. If gamma = 1, beta and sigma are drawn from multivariate normal and inverse wishart. If not Sigma may be drawn around its previous value if randnumber < gamma
                strctident.prior_type_proxy=1; %1=inverse gamma (standard) 2=high relevance , related to the IV routine, priortype for the proxy equation (relevance of the proxy)
            elseif obj.IRFt==6
                strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
                % IV options:
                strctident.Instrument='MHF'; % specify Instrument to identfy Shock
                strctident.startdateIV='1992m2';
                strctident.enddateIV='2003m12';
                strctident.Thin=10;
                strctident.prior_type_reduced_form=1; %1=flat (standard), 2=normal wishart , related to the IV routine
                strctident.Switchprobability=0; % (=0 standard) related to the IV routine, governs the believe of the researcher if the posterior distribution of Sigma|Y as specified by the standard inverse Wishart distribution, is a good proposal distribution for Sigma|Y, IV. If gamma = 1, beta and sigma are drawn from multivariate normal and inverse wishart. If not Sigma may be drawn around its previous value if randnumber < gamma
                strctident.prior_type_proxy=1; %1=inverse gamma (standard) 2=high relevance , related to the IV routine, priortype for the proxy equation (relevance of the proxy)
                % Correlation restriction options:
                strctident.CorrelShock='CorrelShock'; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'correl.shock'
                strctident.CorrelInstrument='MHF'; % provide the IV variable in excel sheet "IV"
            end
            
            obj.strctident = strctident;
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
end