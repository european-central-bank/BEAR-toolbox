function [estimationinfo, status, message] = excelrecord1fcn(endo, exo, Units, opts)
% script excelrecord1

% copy the estimation info into the Excel file

% create the cell storing the information
estimationinfo=cell(107,max([size(endo,1) size(exo,1)+1 size(Units,1)]));

% preliminary element: estimation date
estimationinfo{1,1}=datestr(clock);

% VAR specification

% VAR type
if opts.VARtype==1
    estimationinfo{5,1}='Standard OLS VAR';
elseif opts.VARtype==2
    estimationinfo{5,1}='Bayesian VAR';
elseif opts.VARtype==3
    estimationinfo{5,1}='Mean-adjusted BVAR';
elseif opts.VARtype==4
    estimationinfo{5,1}='Panel BVAR';
elseif opts.VARtype==5
    estimationinfo{5,1}='Stochastic volatility BVAR';
elseif opts.VARtype==6
    estimationinfo{5,1}='Time-varying BVAR';
end

% data opts.frequency
if opts.frequency==1
    estimationinfo{6,1}='yearly';
elseif opts.frequency==2
    estimationinfo{6,1}='quarterly';
elseif opts.frequency==3
    estimationinfo{6,1}='monthly';
elseif opts.frequency==4
    estimationinfo{6,1}='weekly';
elseif opts.frequency==5
    estimationinfo{6,1}='daily';
elseif opts.frequency==6
    estimationinfo{6,1}='undated';
end

% sample start date
estimationinfo{7,1}=opts.startdate;

% sample end date
estimationinfo{8,1}=opts.enddate;

% endogenous variables
for ii=1:size(endo,1)
    estimationinfo{9,ii}=endo{ii,1};
end

% exogenous variables
if opts.const==1
    estimationinfo{10,1}='constant';
end
for ii=1:size(exo,1)
    estimationinfo{10,ii+opts.const}=exo{ii,1};
end

% constant included
if opts.const==1
    estimationinfo{11,1}='yes';
elseif opts.const==0
    estimationinfo{11,1}='no';
end

% lag number
estimationinfo{12,1}=num2str(opts.lags);

% path to the data. This is equivalent to what we had before, but there is
% now one less preference to set.
estimationinfo{13,1}= fileparts(opts.excelFile);

% save preferences. This used to save opts.pref.pref, which was always set
% to zero. This property has been removed and we can consider removing this
% line too.
estimationinfo{14,1}=num2str(0);





% Bayesian VAR: prior specification
if opts.VARtype==2
    
    % prior distribution
    if opts.prior==11
        estimationinfo{18,1}='Minnesota (sigma as univariate AR)';
    elseif opts.prior==12
        estimationinfo{18,1}='Minnesota (sigma as diagonal VAR estimates)';
    elseif opts.prior==13
        estimationinfo{18,1}='Minnesota (sigma as full VAR estimates)';
    elseif opts.prior==21
        estimationinfo{18,1}='normal-wishart (sigma as univariate AR)';
    elseif opts.prior==22
        estimationinfo{18,1}='normal-wishart (sigma as identity)';
    elseif opts.prior==31
        estimationinfo{18,1}='independent normal-wishart (sigma as univariate AR)';
    elseif opts.prior==32
        estimationinfo{18,1}='independent normal-wishart (sigma as identity)';
    elseif opts.prior==41
        estimationinfo{18,1}='normal-diffuse';
    elseif opts.prior==51
        estimationinfo{18,1}='dummy observations';
    end
    
    % ar coefficient
    %estimationinfo{19,1}=num2str(ar);
    for ii=1:size(endo,1)
        estimationinfo{19,ii}=num2str(opts.ar(ii));
    end
    
    % lambda 1
    estimationinfo{20,1}=num2str(opts.lambda1);
    
    % lambda 2
    estimationinfo{21,1}=num2str(opts.lambda2);
    
    % lambda 3
    estimationinfo{22,1}=num2str(opts.lambda3);
    
    % lambda 4
    %estimationinfo{23,1}=num2str(lambda4);
    for ii=1:size(endo,1)
        if isscalar(opts.lambda4)
            estimationinfo{23,ii}=num2str(opts.lambda4);
        else
            estimationinfo{23,ii}=num2str(opts.lambda4(ii));
        end
    end
    
    % lambda 5
    estimationinfo{24,1}=num2str(opts.lambda5);
    
    % lambda 6
    estimationinfo{25,1}=num2str(opts.lambda6);
    
    % lambda 7
    estimationinfo{26,1}=num2str(opts.lambda7);
    
    % total number of iterations
    estimationinfo{27,1}=num2str(opts.It);
    
    % burn-in iterations
    estimationinfo{28,1}=num2str(opts.Bu);
    
    % grid search
    if opts.hogs==1
        estimationinfo{29,1}='yes';
    elseif opts.hogs==0
        estimationinfo{29,1}='no';
    end
    
    % block exogeneity
    if opts.bex==1
        estimationinfo{30,1}='yes';
    elseif opts.bex==0
        estimationinfo{30,1}='no';
    end
    
    % sum-of-coefficients extension
    if opts.scoeff==1
        estimationinfo{31,1}='yes';
    elseif opts.scoeff==0
        estimationinfo{31,1}='no';
    end
    
    % dummy initial observation extension
    if opts.iobs==1
        estimationinfo{32,1}='yes';
    elseif opts.iobs==0
        estimationinfo{32,1}='no';
    end
    
end





% Mean-adjusted BVAR: prior specification
if opts.VARtype==3
    
    % ar coefficient
    estimationinfo{36,1}=num2str(opts.ar);
    
    % lambda 1
    estimationinfo{37,1}=num2str(opts.lambda1);
    
    % lambda 2
    estimationinfo{38,1}=num2str(opts.lambda2);
    
    % lambda 3
    estimationinfo{39,1}=num2str(opts.lambda3);
    
    % lambda 4
    estimationinfo{40,1}=num2str(opts.lambda4);
    
    % lambda 5
    estimationinfo{41,1}=num2str(opts.lambda5);
    
    % total number of iterations
    estimationinfo{42,1}=num2str(opts.It);
    
    % burn-in iterations
    estimationinfo{43,1}=num2str(opts.Bu);
    
    % block exogeneity
    if opts.bex==1
        estimationinfo{44,1}='yes';
    elseif opts.bex==0
        estimationinfo{44,1}='no';
    end
    
end





% Panel VAR: prior specification
if opts.VARtype==4
    
    % panel model
    if opts.panel==1
        estimationinfo{48,1}='mean group estimator (OLS)';
    elseif opts.panel==2
        estimationinfo{48,1}='pooled estimator';
    elseif opts.panel==3
        estimationinfo{48,1}='random effect (Zellner-Hong)';
    elseif opts.panel==4
        estimationinfo{48,1}='random effect (hierarchical)';
    elseif opts.panel==5
        estimationinfo{48,1}='static structural factor';
    elseif opts.panel==6
        estimationinfo{48,1}='dynamic structural factor';
    end
    
    % units
    for ii=1:size(Units,1)
        estimationinfo{49,ii}=Units{ii,1};
    end
    
    % total number of iterations
    estimationinfo{50,1}=num2str(opts.It);
    
    % burn-in iterations
    estimationinfo{51,1}=num2str(opts.Bu);
    
    % post burn selection
    if opts.panel==4 || opts.panel==5 || opts.panel==6
        if opts.pick==1
            estimationinfo{52,1}='yes';
        elseif opts.pick==0
            estimationinfo{52,1}='no';
        end
    end
    
    % opts.frequency of draw selection
    if opts.pick==1
        estimationinfo{53,1}=num2str(opts.pickf);
    end
    
    % ar coefficient
    estimationinfo{54,1}=num2str(opts.ar);
    
    % lambda 1
    estimationinfo{55,1}=num2str(opts.lambda1);
    
    % lambda 2
    estimationinfo{56,1}=num2str(opts.lambda2);
    
    % lambda 3
    estimationinfo{57,1}=num2str(opts.lambda3);
    
    % lambda 4
    estimationinfo{58,1}=num2str(opts.lambda4);
    
    % IG shape on overall tightness s0
    estimationinfo{59,1}=num2str(opts.s0);
    
    % IG scale on overall tightness v0
    estimationinfo{60,1}=num2str(opts.v0);
    
    % IG shape on residual variance alpha0
    estimationinfo{61,1}=num2str(opts.alpha0);
    
    % IG scale on residual variance delta0
    estimationinfo{62,1}=num2str(opts.delta0);
    
    % AR coefficient on residual variance gamma
    estimationinfo{63,1}=num2str(opts.gamma);
    
    % IG shape on factor variance a0
    estimationinfo{64,1}=num2str(opts.a0);
    
    % IG scale on factor variance b0
    estimationinfo{65,1}=num2str(opts.b0);
    
    % AR coefficient on factors rho
    estimationinfo{66,1}=num2str(opts.rho);
    
    % variance of Metropolis draw psi
    estimationinfo{67,1}=num2str(opts.psi);
    
end





% Stochastic volatility BVAR: prior specification
if opts.VARtype==5
    
    % Stochastic volatility model
    if opts.stvol==1
        estimationinfo{71,1}='standard';
    elseif opts.stvol==2
        estimationinfo{71,1}='random inertia';
    elseif opts.stvol==3
        estimationinfo{71,1}='large BVAR';
    elseif opts.stvol==4
        estimationinfo{71,1}='Survey Local Mean Model';
    elseif opts.tvbvar==1
        estimationinfo{71,1}='Var Coefficients';
    elseif opts.tvbvar==2
        estimationinfo{71,1}='General Time varying';
    end
    
    % total number of iterations
    estimationinfo{72,1}=num2str(opts.It);
    
    % burn-in iterations
    estimationinfo{73,1}=num2str(opts.Bu);
    
    if opts.pick==1 || opts.stvol==4
        estimationinfo{74,1}='yes';
    elseif opts.pick==0
        estimationinfo{74,1}='no';
    end
    
    % opts.frequency of draw selection
    if opts.pick==1
        estimationinfo{75,1}=num2str(opts.pickf);
    end
    
    % block exogeneity
    if opts.bex==1
        estimationinfo{76,1}='yes';
    elseif opts.bex==0
        estimationinfo{76,1}='no';
    end
    
    % ar coefficient
    estimationinfo{77,1}=num2str(opts.ar);
    
    % lambda 1
    estimationinfo{78,1}=num2str(opts.lambda1);
    
    % lambda 2
    estimationinfo{79,1}=num2str(opts.lambda2);
    
    % lambda 3
    estimationinfo{80,1}=num2str(opts.lambda3);
    
    % lambda 4
    %estimationinfo{81,1}=num2str(lambda4);
    
    % lambda 5
    estimationinfo{82,1}=num2str(opts.lambda5);
    
    % AR coefficient on residual variance gamma
    estimationinfo{83,1}=num2str(opts.gamma);
    
    if opts.stvol<4
        % IG shape on residual variance alpha0
        estimationinfo{84,1}=num2str(opts.alpha0);
        
        % IG scale on residual variance delta0
        estimationinfo{85,1}=num2str(opts.delta0);
        
        % prior mean on inertia gamma0
        estimationinfo{86,1}=num2str(opts.gamma0);
        
        % prior variance on inertia zeta0
        estimationinfo{87,1}=num2str(opts.zeta0);
    end
    
end




% Time-varying BVAR: prior specification
if opts.VARtype==6
    
    % Stochastic volatility model
    if opts.tvbvar==1
        estimationinfo{91,1}='VAR coefficients';
    elseif opts.tvbvar==2
        estimationinfo{91,1}='General';
    end
    
    % total number of iterations
    estimationinfo{92,1}=num2str(opts.It);
    
    % burn-in iterations
    estimationinfo{93,1}=num2str(opts.Bu);
    
    if opts.pick==1
        estimationinfo{94,1}='yes';
    elseif opts.pick==0
        estimationinfo{94,1}='no';
    end
    
    % opts.frequency of draw selection
    if opts.pick==1
        estimationinfo{95,1}=num2str(opts.pickf);
    end
    
    % AR coefficient on residual variance gamma
    estimationinfo{96,1}=num2str(opts.gamma);
    
    % IG shape on residual variance alpha0
    estimationinfo{97,1}=num2str(opts.alpha0);
    
    % IG scale on residual variance delta0
    estimationinfo{98,1}=num2str(opts.delta0);
    
end



% Model options

% impulse response functions
if opts.IRF==1
    estimationinfo{102,1}='yes';
elseif opts.IRF==0
    estimationinfo{102,1}='no';
end

% unconditional forecasts
if opts.F==1
    estimationinfo{103,1}='yes';
elseif opts.F==0
    estimationinfo{103,1}='no';
end

% forecast error variance decomposition
if opts.FEVD==1
    estimationinfo{104,1}='yes';
elseif opts.FEVD==0
    estimationinfo{104,1}='no';
end

% historical decomposition
if opts.HD==1
    estimationinfo{105,1}='yes';
elseif opts.HD==0
    estimationinfo{105,1}='no';
end

% conditional forecasts
if opts.CF==1 && opts.VARtype~=1
    if opts.VARtype ~= 4 || opts.panel~=1
        estimationinfo{106,1}='yes';
    end
elseif opts.CF==0 && opts.VARtype~=1
    if opts.VARtype ~= 4 || opts.panel~=1
        estimationinfo{106,1}='no';
    end
end

% structural identification
if opts.IRFt==1
    estimationinfo{107,1}='none';
elseif opts.IRFt==2
    estimationinfo{107,1}='Choleski factorisation';
elseif opts.IRFt==3
    estimationinfo{107,1}='triangular factorisation';
elseif opts.IRFt==4
    estimationinfo{107,1}='sign restrictions';
end

% forecast evaluation
if opts.F==1 && opts.Feval==1
    estimationinfo{108,1}='yes';
elseif opts.F==1 && opts.Feval==0
    estimationinfo{108,1}='no';
end

% type of conditional forecasts
if (opts.VARtype==2 || opts.VARtype==3 || (opts.VARtype==4 && opts.panel~=1) || opts.VARtype==5 || opts.VARtype==6) && opts.CF==1
    if opts.CFt==1
        estimationinfo{109,1}='Standard (all shocks)';
    elseif opts.CFt==2
        estimationinfo{109,1}='Standard (shock-specific)';
    elseif opts.CFt==3
        estimationinfo{109,1}='Tilting (median)';
    elseif opts.CFt==4
        estimationinfo{109,1}='Tilting (intervals)';
    end
end

% IRF periods
if opts.IRF==1
    estimationinfo{110,1}=opts.IRFperiods;
end

% forecast start date
if opts.F==1 || opts.CF==1
    estimationinfo{111,1}=opts.Fstartdate;
end

% forecast end date
if opts.F==1 || opts.CF==1
    estimationinfo{112,1}=opts.enddate;
end

% Start forecast after last sample period
if (opts.F==1 || opts.CF==1) && opts.Fendsmpl==1
    estimationinfo{113,1}='yes';
elseif (opts.F==1 || opts.CF==1) && opts.Fendsmpl==0
    estimationinfo{113,1}='no';
end

% credibility level (VAR coefficients)
estimationinfo{114,1}=num2str(opts.cband);

% credibility level (IRF)
if opts.IRF==1
    estimationinfo{115,1}=num2str(opts.IRFband);
end

% credibility level (forecasts)
if opts.F==1 || opts.CF==1
    estimationinfo{116,1}=num2str(opts.Fband);
end

% credibility level (variance decomposition)
if opts.FEVD==1  && opts.VARtype~=1
    if opts.VARtype ~= 4 || opts.panel~=1
        estimationinfo{117,1}=num2str(opts.FEVDband);
    end
end

% credibility level (historical decomposition)
if opts.HD==1 && opts.VARtype~=1
    if opts.VARtype ~= 4 || opts.panel~=1
        estimationinfo{118,1}=num2str(opts.HDband);
    end 
end

% write on excel file
if opts.results==1
    [status,message]=bear.xlswritegeneral(fullfile(opts.results_path, [opts.results_sub '.xlsx']),estimationinfo ,'estimation info','C2');
else
    status = 0;
    message = '';
end

