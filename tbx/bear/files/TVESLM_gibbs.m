
function [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, phi_G_gibbs, phi_V_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs, Psi_gibbs, V_gibbs]=...
    TVESLM_gibbs(priorValues, dataValues, It, Bu, Ys, Yt, YincLags, p, Bhat,q,k, pickf)
%this function draws from the posterior of the TVE SLM model implementation by Ben Schumann (2020)

% inputs:  - structure 'priorValues': contains all the settings and prior information set in TVESLM_prior.m
%          - structure 'dataValues': structure containing the data
%          - integer 'It': Iterations of the gibbs sampler
%          - integer 'Bu': Burn in of the gibbs sampler
%          - matrix 'Ys': Survey local mean data
%          - matrix 'Yt': data used in the training sample for setting the priors and starting values
%          - matrix 'Yinclags': data after removing the training sample 
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_gibbs': record of the draws for VAR coefficients
%          - matrix 'F_gibbs': record of the draws for constant part of the VAR covariance
%          - matrix 'L_gibbs': record of diagonal elements of the time varrying part of the VAR covariance matrix
%          - matrix 'phi_gibbs': record of SV parameter in the state transitition equation of L
%          - matrix 'phi_G_gibbs': record of SV parameter in the measurement equation for the Survey Local mean
%          - matrix 'phi_V_gibbs': record of SV parameter in the state transition equation for the Survey Local mean
%          - matrix 'sigma_gibbs': record of the VAR variance covariance matrix in T (sample end)
%          - cell   'lambda_t_gibbs': record of the time varrying component of the covariance matrix of the VAR
%          - cell   'sigma_t_gibbs': record of the time varrying covariance matrix of the VAR

%% Initialize
%rng('shuffle')
YData  = YincLags;%load data for y
sbar=ones(size(YData,1),1);
YsDataTrue    = Ys;     %safe true survey data including nans
[T,n] = size(YincLags); %number of endogenous variables and sample length
ns = size(Ys,2);        %number of variables with survey local mean

dataValues.n = n;
dataValues.ns = ns;
nThin = 1/pickf;         %thining of MCMC chain
It = It*pickf;
Bu = Bu*pickf;
nSimSave = floor((It-Bu)*nThin); %size of saving matrices
simstep = floor(1/nThin);% index for printing

YsData = YsDataTrue;
for iM = 1:ns% for each survey variable that is not available, fill missings
        Ysnans             = find(isnan(YsData(:, iM)));
        Ysnans(Ysnans == 1) = [];
        YsData(Ysnans, iM)  = YsData(Ysnans-1,iM);
end


startValues.B=zeros(p*n,n); %initialize B (reduced form coefficients)
startValues.Bhat = Bhat;    %initialize B (reduced form coefficients)
startValues.CD=[zeros(1,ns) ones(1,ns)]'; %initialize random walk coefficient matrix for transition equation
startValues.A=eye(n);       %start values for A (constant part of VAR VCV)

startValues.phiH=0.01*ones(n,1); %start value for variance of the stochastic volatility of the VAR residuals
startValues.phiV=0.01*ones(n,1); %start value for variance of the stochastic volatility of the transition equation for the local mean
startValues.phiG=0.01*ones(ns,1);%start value for variance of the stochastic volatility of the measurement equation for the local mean

startValues.h=ones(n,1); %log start value for mean of the stochastic volatility of the VAR residuals
startValues.v=ones(n,1); %start value for variance of the stochastic volatility of the transition equation for the local mean
startValues.g=ones(ns,1);%start value for variance of the stochastic volatility of the measurement equation for the local mean

%% expand start values
Bdraw  = startValues.B;
CDdraw = startValues.CD;
Adraw  = startValues.A;
meanTS = priorValues.meanTS;


%% Create starting H (reduced form VCV) matrices
Adrawinv_H = Adraw\eye(n); 
Hdraw      = repmat(Adrawinv_H*diag(startValues.h)*Adrawinv_H',[1 1 T]); %time varrying VCV matrix
HvarsDraw  = ones(T,1)*startValues.h'; %diagonal of the time varrying VCV matrix of transition equation

%% Create starting V (stochastic VCV of the transition equation)
Vdraw = repmat(startValues.v',T,1); %diagonal of the time varrying VCV matrix of transition equation

%% Create starting G (stochastic VCV of the measurement equation) 
Gdraw = repmat(startValues.g',T,1);

%% start values for the variance of the stochastic volatility processes
phi_Hdraw=startValues.phiH';
phi_Vdraw=startValues.phiV;
phi_Gdraw=startValues.phiG;



%% intial state space representation
KFSmatrices = makeMatricesSLMfullSV(dataValues,p);

%%Start values for Ben sampler
h0 = priorValues.mean_ln_h0; %initialize initial variance 
Kh0 = diag(priorValues.var_ln_h0); %initialize initial variance 

% normal mixture
pj = [0.0073 .10556 .00002 .04395 .34001 .24566 .2575]; 
mj = [-10.12999 -3.97281 -8.56686 2.77786 .61942 1.79518 -1.08819]- 1.2704;  % caution: means are adjusted!
sigj2 = [5.79596 2.61369 5.17950 .16735 .64009 .34023 1.26261];
sigj = sqrt(sigj2);

H=speye(T-p)-sparse(diag(priorValues.gamma*ones(T-p-1,1),-1));
HH = H'*H; %generate H as random walk


%% storage matrices

% initiate the record matrices and cells
beta_gibbs=[]; %VAR coefficients
Psi_gibbs={};  %local mean
F_gibbs=[];    %Below diagonal elements of F matrix in the decomposition of VAR VCV
L_gibbs=[];    %diagonal elements of L matrix in the decomposition of VAR VCV
V_gibbs=[];    %stochastic Volatility of local mean transition equation
phi_gibbs=[];  %variance of shocks in random walk of elements in L
phi_V_gibbs=[]; %variance of shocks in random walk of elements in V
phi_G_gibbs=[]; %variance of shocks in random walk of elements in G
sigma_gibbs=[]; %last period VCV
lambda_t_gibbs={}; %time varying elements of L 
sigma_t_gibbs={};  %time varying VAR VCV

%% start the Gibbs sampler
hbar = parfor_progressbar(It,'Progress of Gibbs Sampler');  %create the progress bar

for isim = 1:It
    hbar.iterate(1);   % update progress by one iteration
    stationary=0;
    while stationary==0
    % sample the local mean
    PsiDraw_prop = samplePsi_DK(YData,YsData, Bdraw,Hdraw,Vdraw,Gdraw,CDdraw,meanTS,priorValues.kappa,dataValues,KFSmatrices);
    % sample missing survey data
    zData_prop = constructMissingSurvey(YsDataTrue, Gdraw, PsiDraw_prop, dataValues);
    % sample the stochastic volatility components in the measurement equation for the survey data and their variances    
   [Gdraw_prop,phi_Gdraw_prop] = sampleG(zData_prop,PsiDraw_prop,CDdraw,phi_Gdraw,Gdraw,priorValues,dataValues);
    % sample the stochastic volatility components of the VAR residuals   
   %[Hdraw_prop,HvarsDraw_prop,phi_Hdraw_prop,Adraw_prop] =sampleH(YData,PsiDraw_prop,Adraw,Bdraw,phi_Hdraw,HvarsDraw,priorValues,dataValues);
   [Hdraw_prop,HvarsDraw_prop,phi_Hdraw_prop,Adraw_prop,h0,Kh0]=sampleH_update(YData,PsiDraw_prop,Adraw,Bdraw,phi_Hdraw,HvarsDraw,priorValues,dataValues,h0,Kh0);
   %[Hdraw_prop, HvarsDraw_prop, phi_Hdraw_prop, Adraw_prop,h0]=sampleH_MHstep(YData,PsiDraw_prop,Adraw,Bdraw,phi_Hdraw,HvarsDraw,priorValues,dataValues,n,h0);
   %[Hdraw_prop, HvarsDraw_prop, phi_Hdraw_prop, Adraw_prop,h0]=sampleH_Ben(YData,PsiDraw_prop,Adraw,Bdraw,phi_Hdraw',HvarsDraw,priorValues,dataValues,n,h0,HH);
   % sample the stochastic volatility components of the transition equation for the local mean    
    [Vdraw_prop,phi_Vdraw_prop] = sampleV(PsiDraw_prop,phi_Vdraw,Vdraw,priorValues,dataValues);
    % sample the VAR coefficients
   [Bdraw_prop,stationary]=sampleBinw(YData,PsiDraw_prop,Hdraw_prop,p,priorValues, q, k);
    end
    
    %rename
            Hdraw     = Hdraw_prop;
            HvarsDraw = HvarsDraw_prop;
            phi_Hdraw = phi_Hdraw_prop;
            Adraw     = Adraw_prop;
            Vdraw     = Vdraw_prop;
            phi_Vdraw = phi_Vdraw_prop;
            Gdraw     = Gdraw_prop;
            phi_Gdraw = phi_Gdraw_prop;
            PsiDraw   = PsiDraw_prop;
            Bdraw     = Bdraw_prop;

     
        % save the draws
    if isim > Bu && mod( isim - Bu, simstep ) == 0
      % record the results
      isave = ( isim - Bu ) / simstep;
      beta_gibbs(:,isave)=vec(Bdraw);
      F_gibbs(:,:,isave)=Adraw\eye(n);
      L_gibbs(:,:,isave)=HvarsDraw;
      V_gibbs(:,:,isave)=Vdraw;
      phi_gibbs(isave,:)=phi_Hdraw;
      phi_G_gibbs(isave,:)=phi_Gdraw;
      phi_V_gibbs(isave,:)=phi_Vdraw;
      sigma_gibbs(:,isave)=vec(Hdraw(:,:,T));
         for jj=1:T
         lambda_t_gibbs{jj,1}(:,:,isave)=diag(HvarsDraw(jj,:));
         sigma_t_gibbs{jj,1}(:,:,isave)=Hdraw(:,:,jj);
         end 
         
         for ii=1:n
             Psi_gibbs{1,ii}(:,isave)=PsiDraw(:,ii);
         end 
    end
end 



close(hbar);   %close progress bar

