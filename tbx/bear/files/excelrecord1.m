% script excelrecord1








% copy the estimation info into the Excel file

% create the cell storing the information
estimationinfo=cell(107,max([size(endo,1) size(exo,1)+1 size(Units,1)]));

% preliminary element: estimation date
estimationinfo{1,1}=datestr(clock);





% VAR specification

% VAR type
if VARtype==1
estimationinfo{5,1}='Standard OLS VAR';
elseif VARtype==2
estimationinfo{5,1}='Bayesian VAR';
elseif VARtype==3
estimationinfo{5,1}='Mean-adjusted BVAR';
elseif VARtype==4
estimationinfo{5,1}='Panel BVAR';
elseif VARtype==5
estimationinfo{5,1}='Stochastic volatility BVAR';
elseif VARtype==6
estimationinfo{5,1}='Time-varying BVAR';
end

% data frequency
if frequency==1
estimationinfo{6,1}='yearly';
elseif frequency==2
estimationinfo{6,1}='quarterly';
elseif frequency==3
estimationinfo{6,1}='monthly';
elseif frequency==4
estimationinfo{6,1}='weekly';
elseif frequency==5
estimationinfo{6,1}='daily';
elseif frequency==6
estimationinfo{6,1}='undated';
end

% sample start date
estimationinfo{7,1}=startdate;

% sample end date
estimationinfo{8,1}=enddate;

% endogenous variables
for ii=1:size(endo,1)
estimationinfo{9,ii}=endo{ii,1};
end

% exogenous variables
if const==1
estimationinfo{10,1}='constant';
end
for ii=1:size(exo,1)
estimationinfo{10,ii+const}=exo{ii,1};
end

% constant included
if const==1
estimationinfo{11,1}='yes';
elseif const==0
estimationinfo{11,1}='no';
end

% lag number
estimationinfo{12,1}=num2str(lags);

% path to the data
estimationinfo{13,1}=pref.datapath;

% save preferences
estimationinfo{14,1}=num2str(pref.pref);





% Bayesian VAR: prior specification
if VARtype==2

% prior distribution
if prior==11
estimationinfo{18,1}='Minnesota (sigma as univariate AR)';
elseif prior==12
estimationinfo{18,1}='Minnesota (sigma as diagonal VAR estimates)';
elseif prior==13
estimationinfo{18,1}='Minnesota (sigma as full VAR estimates)';
elseif prior==21
estimationinfo{18,1}='normal-wishart (sigma as univariate AR)';
elseif prior==22
estimationinfo{18,1}='normal-wishart (sigma as identity)';
elseif prior==31
estimationinfo{18,1}='independent normal-wishart (sigma as univariate AR)';
elseif prior==32
estimationinfo{18,1}='independent normal-wishart (sigma as identity)';
elseif prior==41
estimationinfo{18,1}='normal-diffuse';
elseif prior==51
estimationinfo{18,1}='dummy observations';   
end

% ar coefficient
%estimationinfo{19,1}=num2str(ar);
for ii=1:size(endo,1)
estimationinfo{19,ii}=num2str(ar(ii));
end

% lambda 1
estimationinfo{20,1}=num2str(lambda1);

% lambda 2
estimationinfo{21,1}=num2str(lambda2);

% lambda 3
estimationinfo{22,1}=num2str(lambda3);

% lambda 4
%estimationinfo{23,1}=num2str(lambda4);
for ii=1:size(endo,1)
estimationinfo{23,ii}=num2str(lambda4(ii));
end

% lambda 5
estimationinfo{24,1}=num2str(lambda5);

% lambda 6
estimationinfo{25,1}=num2str(lambda6);

% lambda 7
estimationinfo{26,1}=num2str(lambda7);

% total number of iterations
estimationinfo{27,1}=num2str(It);

% burn-in iterations
estimationinfo{28,1}=num2str(Bu);

% grid search
if hogs==1
estimationinfo{29,1}='yes';
elseif hogs==0
estimationinfo{29,1}='no';
end

% block exogeneity
if bex==1
estimationinfo{30,1}='yes';
elseif bex==0
estimationinfo{30,1}='no';
end

% sum-of-coefficients extension
if scoeff==1
estimationinfo{31,1}='yes';
elseif scoeff==0
estimationinfo{31,1}='no';
end

% dummy initial observation extension
if iobs==1
estimationinfo{32,1}='yes';
elseif iobs==0
estimationinfo{32,1}='no';
end

end





% Mean-adjusted BVAR: prior specification
if VARtype==3

% ar coefficient
estimationinfo{36,1}=num2str(ar);

% lambda 1
estimationinfo{37,1}=num2str(lambda1);

% lambda 2
estimationinfo{38,1}=num2str(lambda2);

% lambda 3
estimationinfo{39,1}=num2str(lambda3);

% lambda 4
estimationinfo{40,1}=num2str(lambda4);

% lambda 5
estimationinfo{41,1}=num2str(lambda5);

% total number of iterations
estimationinfo{42,1}=num2str(It);

% burn-in iterations
estimationinfo{43,1}=num2str(Bu);

% block exogeneity
if bex==1
estimationinfo{44,1}='yes';
elseif bex==0
estimationinfo{44,1}='no';
end

end





% Panel VAR: prior specification
if VARtype==4

% panel model
if panel==1
estimationinfo{48,1}='mean group estimator (OLS)';
elseif panel==2
estimationinfo{48,1}='pooled estimator';
elseif panel==3
estimationinfo{48,1}='random effect (Zellner-Hong)';
elseif panel==4
estimationinfo{48,1}='random effect (hierarchical)';
elseif panel==5
estimationinfo{48,1}='static structural factor';
elseif panel==6
estimationinfo{48,1}='dynamic structural factor';
end

% units
for ii=1:size(Units,1)
estimationinfo{49,ii}=Units{ii,1};
end

% total number of iterations
estimationinfo{50,1}=num2str(It);

% burn-in iterations
estimationinfo{51,1}=num2str(Bu);

% post burn selection
if panel==4 || panel==5 || panel==6
   if pick==1
   estimationinfo{52,1}='yes';
   elseif pick==0
   estimationinfo{52,1}='no';
   end
end

% frequency of draw selection
if pick==1
estimationinfo{53,1}=num2str(pickf);
end

% ar coefficient
estimationinfo{54,1}=num2str(ar);

% lambda 1
estimationinfo{55,1}=num2str(lambda1);

% lambda 2
estimationinfo{56,1}=num2str(lambda2);

% lambda 3
estimationinfo{57,1}=num2str(lambda3);

% lambda 4
estimationinfo{58,1}=num2str(lambda4);

% IG shape on overall tightness s0
estimationinfo{59,1}=num2str(s0);

% IG scale on overall tightness v0
estimationinfo{60,1}=num2str(v0);

% IG shape on residual variance alpha0
estimationinfo{61,1}=num2str(alpha0);

% IG scale on residual variance delta0
estimationinfo{62,1}=num2str(delta0);

% AR coefficient on residual variance gamma
estimationinfo{63,1}=num2str(gama);

% IG shape on factor variance a0
estimationinfo{64,1}=num2str(a0);

% IG scale on factor variance b0
estimationinfo{65,1}=num2str(b0);

% AR coefficient on factors rho
estimationinfo{66,1}=num2str(rho);

% variance of Metropolis draw psi
estimationinfo{67,1}=num2str(psi);

end





% Stochastic volatility BVAR: prior specification
if VARtype==5

% Stochastic volatility model
if stvol==1
estimationinfo{71,1}='standard';
elseif stvol==2
estimationinfo{71,1}='random inertia';
elseif stvol==3
estimationinfo{71,1}='large BVAR';
elseif stvol==4
estimationinfo{71,1}='Survey Local Mean Model';
elseif tvbvar==1
estimationinfo{71,1}='Var Coefficients';
elseif tvbvar==2
estimationinfo{71,1}='General Time varying';
end

% total number of iterations
estimationinfo{72,1}=num2str(It);

% burn-in iterations
estimationinfo{73,1}=num2str(Bu);

if pick==1 || stvol==4
estimationinfo{74,1}='yes';
elseif pick==0
estimationinfo{74,1}='no';
end

% frequency of draw selection
if pick==1
estimationinfo{75,1}=num2str(pickf);
end

% block exogeneity
if bex==1
estimationinfo{76,1}='yes';
elseif bex==0
estimationinfo{76,1}='no';
end

% ar coefficient
estimationinfo{77,1}=num2str(ar);

% lambda 1
estimationinfo{78,1}=num2str(lambda1);

% lambda 2
estimationinfo{79,1}=num2str(lambda2);

% lambda 3
estimationinfo{80,1}=num2str(lambda3);

% lambda 4
%estimationinfo{81,1}=num2str(lambda4);

% lambda 5
estimationinfo{82,1}=num2str(lambda5);

% AR coefficient on residual variance gamma
estimationinfo{83,1}=num2str(gamma);

if stvol<4
% IG shape on residual variance alpha0
estimationinfo{84,1}=num2str(alpha0);

% IG scale on residual variance delta0
estimationinfo{85,1}=num2str(delta0);

% prior mean on inertia gamma0
estimationinfo{86,1}=num2str(gamma0);

% prior variance on inertia zeta0
estimationinfo{87,1}=num2str(zeta0);
end

end




% Time-varying BVAR: prior specification
if VARtype==6

% Stochastic volatility model
if tvbvar==1
estimationinfo{91,1}='VAR coefficients';
elseif tvbvar==2
estimationinfo{91,1}='General';
end

% total number of iterations
estimationinfo{92,1}=num2str(It);

% burn-in iterations
estimationinfo{93,1}=num2str(Bu);

if pick==1
estimationinfo{94,1}='yes';
elseif pick==0
estimationinfo{94,1}='no';
end

% frequency of draw selection
if pick==1
estimationinfo{95,1}=num2str(pickf);
end

% AR coefficient on residual variance gamma
estimationinfo{96,1}=num2str(gamma);

% IG shape on residual variance alpha0
estimationinfo{97,1}=num2str(alpha0);

% IG scale on residual variance delta0
estimationinfo{98,1}=num2str(delta0);

end



% Model options

% impulse response functions
if IRF==1
estimationinfo{102,1}='yes';
elseif IRF==0
estimationinfo{102,1}='no';
end

% unconditional forecasts
if F==1
estimationinfo{103,1}='yes';
elseif F==0
estimationinfo{103,1}='no';
end

% forecast error variance decomposition
if FEVD==1
estimationinfo{104,1}='yes';
elseif FEVD==0
estimationinfo{104,1}='no';
end

% historical decomposition
if HD==1
estimationinfo{105,1}='yes';
elseif HD==0
estimationinfo{105,1}='no';
end

% conditional forecasts
if CF==1 && VARtype~=1 && panel~=1
estimationinfo{106,1}='yes';
elseif CF==0 && VARtype~=1 && panel~=1
estimationinfo{106,1}='no';
end

% structural identification
if IRFt==1
estimationinfo{107,1}='none';
elseif IRFt==2
estimationinfo{107,1}='Choleski factorisation';
elseif IRFt==3
estimationinfo{107,1}='triangular factorisation';
elseif IRFt==4
estimationinfo{107,1}='sign restrictions';
end

% forecast evaluation
if F==1 && Feval==1
estimationinfo{108,1}='yes';
elseif F==1 && Feval==0
estimationinfo{108,1}='no';
end

% type of conditional forecasts
if (VARtype==2 || VARtype==3 || (VARtype==4 && panel~=1) || VARtype==5 || VARtype==6) && CF==1
   if CFt==1
   estimationinfo{109,1}='Standard (all shocks)';  
   elseif CFt==2
   estimationinfo{109,1}='Standard (shock-specific)';
   elseif CFt==3
   estimationinfo{109,1}='Tilting (median)';    
   elseif CFt==4
   estimationinfo{109,1}='Tilting (intervals)';     
   end
end

% IRF periods
if IRF==1
estimationinfo{110,1}=IRFperiods;
end

% forecast start date
if F==1 || CF==1
estimationinfo{111,1}=Fstartdate;
end

% forecast end date
if F==1 || CF==1
estimationinfo{112,1}=Fenddate;
end

% Start forecast after last sample period
if (F==1 || CF==1) && Fendsmpl==1 
estimationinfo{113,1}='yes';
elseif (F==1 || CF==1) && Fendsmpl==0
estimationinfo{113,1}='no';
end

% credibility level (VAR coefficients)
estimationinfo{114,1}=num2str(cband);

% credibility level (IRF)
if IRF==1
estimationinfo{115,1}=num2str(IRFband);
end

% credibility level (forecasts)
if F==1 || CF==1
estimationinfo{116,1}=num2str(Fband);
end

% credibility level (variance decomposition)
if FEVD==1  && VARtype~=1 && panel~=1
estimationinfo{117,1}=num2str(FEVDband);
end

% credibility level (historical decomposition)
if HD==1  && VARtype~=1 && panel~=1
estimationinfo{118,1}=num2str(HDband);
end

% write on excel file
if pref.results==1
    [status,message]=xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],estimationinfo ,'estimation info','C2');
end

