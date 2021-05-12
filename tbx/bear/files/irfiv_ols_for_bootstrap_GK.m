function [D,D1ols,q,C]=irfiv_ols_for_bootstrap_GK(txt,names,IVrotate,betadraw,n,Xdraw,Ydraw,k,p,enddate,startdate,cut1,cut2,cut3,cut4)
%% Copyright Ben Schumann
% function [D, gamma]=irfiv_ols(names, betahat,sigmahat, n,X,Y,k,p,enddate,startdate)
% instrumental variable identification in an OLS setting
% inputs:  - matrix 'betahat': vec(OLS estimates of the reduced form)
%          - matrix 'sigmahat': vec(OLS estimates of sigma)
%          - matrix 'X': Independend Variable
%          - matrix 'Y': Dependend Variable
%          - matrix 'IV': Rotated IV from wild bootstrap
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the VAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the VAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of observations
%          - string  'stardate': VAR startdate
%          - string  'enddate': VAR enddate
% outputs: - matrix 'D': record of the accepted draws for the structural matrix D
%          - matrix 'gamma': record of the draws for the structural disturbances variance-covariance matrix gamma
IV = IVrotate; 
%% Preparation for first stage regression
%get reduced form residuals
beta = betadraw;
B    = reshape(beta,k,n);
EPS  = Ydraw-Xdraw*B;

[EPSIV,IVcut] = cut_EPS_IV_GK_new(txt, names, EPS, IV, cut1, cut2, cut3, cut4, startdate, enddate, p);

%% Imposing the covariance restrictions 
%E_1 = EPSIV'*IVcut/length(IVcut);
%E11 = E_1(1,:);
%E21 = E_1(2:end,:);
%Mu = E21*E11^(-1); %relative impulse vector
%% normalize to a one standard deviation shock
sigmahatIV=(1/(length(EPSIV)-k))*(EPSIV'*EPSIV); 

%get the gamma vector
%partition the reduced form VCV
%Sigma11 = sigmahatIV(1,1);
%Sigma12 = sigmahatIV(1,2:end);
%Sigma21 = sigmahatIV(2:end,1);   
%Sigma22 = sigmahatIV(2:end,2:end); 

%Gamma = Sigma22 + Mu*Sigma11*Mu' - Sigma21*Mu' - Mu*Sigma21'; %%%%%Gamma ouput is not used after this
%get b12 as in Michelle Piffers notes
%b12b12t = (Sigma21-Mu*Sigma11)'*Gamma^(-1)*(Sigma21-Mu*Sigma11);
%b11b11t = Sigma11 - b12b12t;
% b11 = chol(nspd(b11b11t)); %%this is the scaling vector 

%% first stage regression (this results in the same vector as Mu)

%step 2: Regress the first reduced form shock on the instrument
Shock = EPSIV(:,1);
[nobs , ~] = size(IVcut);
XX = [ones(nobs,1) IVcut];
[~, nvar] = size(XX);
%get OLS estimate
XpXi = (XX'*XX)\eye(nvar);
betaIV=XpXi*(XX'*Shock);
%get predicted value
IVpred = XX*betaIV;

%% second stage regression
%step 3: Regress the other reduced form shocks on the predicted value
ImpactIRFIV = zeros(n,1);
ImpactIRFIV(1,1) = 1;

for hh=2:n
Shock = EPSIV(:,hh);
[nobs,~]= size(IVpred);
IVpredtemp = [ones(nobs,1) IVpred];
[~,nvar] = size(IVpredtemp);
IVpIVi = (IVpredtemp'*IVpredtemp)\eye(nvar);
betaIV2=IVpIVi*(IVpredtemp'*Shock);
ImpactIRFIV(hh,1) = betaIV2(2,1); %should be equal to Mu from 2:end
end


% step 5: Create the structural matrix and only fill the first column as
% this is the only one identified
D=zeros(n,n);
% Step 6: Replace the first Column in the Cholesky Decomposition by 
%the structural impact matrix computed above
%%another way to retrieve b11 (the scalar that scales the IRF to be a 1sdt Shock) is simply
C=chol(nspd(sigmahatIV),'lower');
b=ImpactIRFIV;
%%Recover the vector q that maps the first column of C into b such that Cq=b;
q = C\b;
%%b11 is the euclidian length of q
b11q = 1/norm(q);

%
D(1:end,1) = ImpactIRFIV*b11q;
D1ols = ImpactIRFIV*b11q; % for the IRFt6 TakeOLS option


