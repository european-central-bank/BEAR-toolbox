function [beta_draws,sigma_draws,IV_draws,C_draws,D_draws,gamma_draws,irf_storage,ETA_storage,It,Bu]=...
    irfIV_MH(EPSIV,IVcut,betahat,sigmahatIV,sigma_hat,inv_sigma_hat,IV,txt,cut1,cut2,cut3,cut4,names,It,Bu,n,arvar,lambda1,lambda3,lambda4,m,p,k,q,X,Y,T,startdate,enddate,pref,strctident,IRFperiods,IRFt)
rand('seed',1);
randn('seed',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%OLS estimate for initiliasation %%%%%%%%%%%%%%

%% first stage regression

%step 2: Regress the first reduced form shock on the instrument
Shock = EPSIV(:,1);
[nobs,~] = size(IVcut); 
XX = [ones(nobs,1) IVcut];
[~,nvar] = size(XX); 
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
[nobs,~] = size(IVpred); 
IVpredtemp = [ones(nobs,1) IVpred];
[~,nvar] = size(IVpredtemp); 
IVpIVi = (IVpredtemp'*IVpredtemp)\eye(nvar);
betaIV2=IVpIVi*(IVpredtemp'*Shock);
ImpactIRFIV(hh,1) = betaIV2(2,1); %should be equal to Mu from 2:end
end
C=chol(nspd(sigmahatIV),'lower');
b=ImpactIRFIV;
%%Recover the vector q that maps the first column of C into b such that Cq=b;
qols = C\b;
%%%%%%%%%%%%%%%%%%%%%%End of OLS Estimate%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MCMC Chain preliminaries
It=It*strctident.Thin; %It=It*100;
Bu = It/strctident.Thin; 

Acc=It-Bu; %minimum accepted draws
% initialise output variables, that store the draws
beta_draws = nan(k*n,Acc/strctident.Thin); 
sigma_draws=nan(n^2,Acc/strctident.Thin);
IV_draws=nan(n,Acc/strctident.Thin);
D_draws=nan(n^2,Acc/strctident.Thin);
C_draws=nan(n^2,Acc/strctident.Thin);
relevance_draws=nan(1,Acc/strctident.Thin);
gamma_draws=zeros(n^2,Acc/strctident.Thin);
irf_storage=cell(Acc/strctident.Thin,1);% storage cell
ETA_storage=cell(Acc/strctident.Thin,1);
aux1 = inv(X'*X);
%% Preliminaries for the sampler
bet = 0.01;   %%initial guess for beta in the IV regression
signu = 0.04;  %%initial guess for variance of messurement error in the IV regression

% mu0 = 0.00;                             % prior mean for beta 
% V0 = 0.1^2;                             % prior variance inverse Gamma prior
s0 = 0.02;                              % centering coefficient of the inverse gamma prior
nu0 = 2.00;                             % degrees of freedom for the inverse gamma prior
pr_trunc = 0.5;                         % share of variance of explained in the proxy equation under the for high relevance prior

%if the model uses a tighter normal wishart as proposal density

if strctident.prior_type_reduced_form==2
%lambda1 = 0.1; %overall tightness
%lambda3=1; %scaling coefficient for lags
%lambda4=100; %tightness for exogenous variables
[Bbar,~,aux1,vt,Sbar]=nwprior_for_IV(arvar,lambda1,lambda3,lambda4,m,p,k,q,X,Y,T,sigma_hat,betahat,n);
betahat=vec(Bbar);
%sigmahat_prior=nspd(St);
% inv_sigma_hat=sigmahat\eye(n);
elseif strctident.prior_type_reduced_form==1
    vt=T;
end

%% Proposal draws to initiate the algorithm
if strctident.prior_type_reduced_form==1
vt=T;
Q=qols;
sigma_draw=sigma_hat;
%inv_sigma_draw=inv_sigma_hat_ols;
B_draw    = reshape(betahat,k,n); %reshape
hsigma=chol(nspd(sigma_draw),'lower'); %get the cholesky decomposition of the proposal matrix
EPS_draw  = Y-X*B_draw; %calculate reduced form residuals
[EPScut,IVcut]=cut_EPS_IV_GK_new(txt, names, EPS_draw, IV, cut1, cut2, cut3, cut4, startdate, enddate, p); %cut the reduced form residuals
D1inv = Q'/hsigma; %Compute A0inv(:,1);
ETA1 = (D1inv*EPScut(1:end, :)')'; %Shock corresponding to the IV (first shock)
bet = inv(ETA1'*ETA1)*ETA1'*IVcut; %OLS estimator of regression of shock on proxy
z = IVcut - bet*ETA1;
signu = std(z); %standard deviation of error of regression equation
else 
sigma_draw=iwdraw(Sbar,vt);
%inv_sigma_draw=sigma_draw\eye(n);
aux2 = kron(sigma_draw, aux1);
beta_draw = mvnrnd(betahat,aux2);%% Draw beta from a multivariate normal given the draw for sigma
B_draw    = reshape(beta_draw,k,n); %reshape
EPS_draw  = Y-X*B_draw; %calculate reduced form residuals
hsigma=chol(nspd(sigma_draw),'lower'); %get the cholesky decomposition of the proposal matrix
%proposal draw for structural form
Rotationdraws = randn(n, 1); %draw a random column of the rotation matrix
Q = Rotationdraws / norm(Rotationdraws);
%cut the reduced form errors, if the instrument does not correspond to the 
[EPScut, IVcut]=cut_EPS_IV_GK_new(txt, names, EPS_draw, IV, cut1, cut2, cut3, cut4, startdate, enddate, p); %cut the reduced form residuals
end
%compute the conditional likelihood of the proxy given the reduced form residuals
c_ll_proxy0 = loglik_proxy_given_data(IVcut, EPScut(1:end, :), hsigma, Q, bet, signu); %log likelihood of the proxy given the draw for beta and sigma

AA=0; 
acpt_reduced_form=0;
acpt_Q=0;
keep = 0;   
%% Metropolis Hastings within Gibs Sampling Algorithm
hbar=parfor_progressbar(Acc+Bu,'Posterior draws of the Proxy SVAR');
while AA<Acc+Bu
        %------------------------------------------------------------
        % Draw from the conditional probability of the reduced form VAR
        %------------------------------------------------------------
        % Step 1: Draw from the marginal posterior for Sigmau p(Sigma|Y,IV)
 if (rand()>strctident.Switchprobability) 
         %proposal draws for the reduced form
         if strctident.prior_type_reduced_form==1
             R=mvnrnd(zeros(n,1),inv_sigma_hat/T,T)'; %draw sigma from inverse wishart around OLS estimate
             sigma_draw_star=(R*R')\eye(n);
         else
             sigma_draw_star=iwdraw(Sbar,vt);
         end
        % Step 2: Draw from the condition posterior for beta p(beta|Y,IV)
         
         aux2 = kron(sigma_draw_star, aux1); %%auxilary kronecker product between X*X'and the new draw
         beta_draw_star = mvnrnd(betahat,aux2);%% Draw beta from a multivariate normal given the draw for sigma
         B_draw_star    = reshape(beta_draw_star,k,n); %reshape
         EPS_draw_star  = Y-X*B_draw_star; %compute reduced form residuals
         hsigma_star=chol(nspd(sigma_draw_star),'lower'); %get the cholesky decomposition of the proposal matrix
         %A0cholstar    = (hsigma_star')\eye(size(hsigma_star,1)); %get A0 of cholesky;
         [EPScut_star,IVcut]=cut_EPS_IV_GK_new(txt, names, EPS_draw_star, IV, cut1, cut2, cut3, cut4, startdate, enddate, p); %cut the reduced form residuals
         c_ll_proxy_star = loglik_proxy_given_data(IVcut, EPScut_star(1:end, :), hsigma_star, Q, bet, signu); %log likelihood of the proxy given the draw for beta and sigma
         
         % metropolis hastings acceptance probability
         mhap = exp(c_ll_proxy_star - c_ll_proxy0);
     
     
 else
        %if random number is below the gamma use this part. By default its not used
        %if random number is below the gamma use this part use a random
        %walk normal wishart as proposal
        sigma_draw_star=iwdraw(vt*sigma_draw,vt); %draw sigma conditional on its previous value
        aux2 = kron(sigma_draw_star, aux1); %%auxilary kronecker product between X*X'and the new draw
        beta_draw_star = mvnrnd(betahat,aux2);%% Draw beta from a multivariate normal given the draw for sigma
        B_draw_star    = reshape(beta_draw_star,k,n); %reshape
        EPS_draw_star  = Y-X*B_draw_star; %compute reduced form residuals
        hsigma_star=chol(nspd(sigma_draw_star),'lower'); %get the cholesky decomposition of the proposal matrix
        [EPScut_star, IVcut, ~, ~, ~]=cut_EPS_IV_GK_new(txt, names, EPS_draw_star, IV, cut1, cut2, cut3, cut4, startdate, enddate, p); %cut the reduced form residuals
                
        %compute likelihood of the new draw, given the previous rotation
        %matrix, beta and sign (variance of the mesurement error)
        c_ll_proxy_star = loglik_proxy_given_data(IVcut, EPScut_star(1:end, :), hsigma_star, Q, bet, signu); %log likelihood of the proxy given the draw for beta and sigma
        
        c_lpdf_of_sigma_star      = pdf_ln_iwish(sigma_draw*vt, vt+n+1, sigma_draw_star); %likelihood of sigmadraw condition on sigmadraw_star
        c_lpdf_of_sigma0          = pdf_ln_iwish(sigma_draw_star*vt, vt+n+1, sigma_draw); %likelihood of sigmadraw_star condition on sigmadraw
        
        uc_lpdf_of_sigma_star = pdf_ln_iwish(sigma_hat*vt, T-p*n-1, sigma_draw_star); %unconditional likelihood of sigmadrawstar
        uc_lpdf_of_sigma0     = pdf_ln_iwish(sigma_hat*vt, T-p*n-1, sigma_draw);     %unconditional likelihood of sigmadraw
        
        % metropolis hastings acceptance probability
        mhap = exp((c_ll_proxy_star+uc_lpdf_of_sigma_star) - (c_ll_proxy0+uc_lpdf_of_sigma0) - (c_lpdf_of_sigma_star - c_lpdf_of_sigma0));
 end

 % Accept the draw for the reduced form coefficients, if the likelihood of
 % the proxy given the reduced form variables is larger than the random
 % number, if the ratio is larger than 1, accept the new draw with
 % certainty
 if rand < mhap
 c_ll_proxy0 = c_ll_proxy_star; %reset conditional likelihood of the proxy
 EPScut = EPScut_star; %reset reduced form residual cut draw
 hsigma = hsigma_star; %reset cholesky decomposition
 sigma_draw = sigma_draw_star; %reset VCV
  beta_draw = beta_draw_star;
 acpt_reduced_form = acpt_reduced_form+1; %iterate reduced form acceptance
  end
 %------------------------------------------------------------
        % STEP TWO: Draw from Q uniform distribution
%------------------------------------------------------------
        Rotationdrawsstar = randn(n, 1); %draw one colum of Q
        Qstar = Rotationdrawsstar / norm(Rotationdrawsstar); %normalize
        
       % normalize D1
        D1star = hsigma*Qstar; 
        if D1star(1,1) < 0
            Qstar = -Qstar;
            %D1star = hsigma*Qstar;
        end     
        
        c_ll_proxy_star = loglik_proxy_given_data(IVcut, EPScut(1:end, :), hsigma, Qstar, bet, signu); %calculate conditional likelihood of the proxy given the new rotation matrix
        %metropolis hastings acceptance probability
        mhap = exp(c_ll_proxy_star - c_ll_proxy0);
        
        if rand < mhap
        %c_ll_proxy0=c_ll_proxy_star;
        Q = Qstar;
        acpt_Q = acpt_Q+1;
        end
  
         %------------------------------------------------------------
        % STEP THREE: draw beta (regression coefficient of shocks on proxy
        % and SIGMA from MVN-IG / MVN-IW
        %------------------------------------------------------------
        D1inv = Q' / hsigma; %compute inverse of first column of structural impact matrix
        ETA1 = (D1inv*EPScut(1:end, :)')'; %Shock corresponding to the IV (first shock)
        Vp = inv(ETA1'*ETA1);              
        Bhat = Vp*ETA1'*IVcut; 

        if strctident.prior_type_proxy==1 %draw from inverse gamma          
            nu1 = size(ETA1, 1)-1 + nu0; %
            s1 = ( (IVcut-ETA1*Bhat)'*(IVcut-ETA1*Bhat) + nu0*s0^2)/nu1;
            %draw from inverse gamma
            x = randn(nu1, 1);
            signu = sqrt(nu1*s1 / sum(x.^2));

        elseif strctident.prior_type_proxy==2 %fix signu to 0.5 (high relevance prior)     
            signu = pr_trunc*std(IVcut);
        end
 
        bet = mvnrnd(Bhat, signu^2*Vp); %update believe about bet
        %finally reset log likelihood for the entire draw
        c_ll_proxy0 = loglik_proxy_given_data(IVcut, EPScut_star(1:end, :), hsigma_star, Q, bet, signu); %calculate conditional likelihood of the proxy given the new rotation matrix
        AA=AA+1;
        
        if AA > Bu
        rem = AA/strctident.Thin; %only keep every 10th iteration
        if floor(rem)==rem
        keep=keep+1;
        beta_draws(:,keep)=beta_draw; %reduced form coefficients
        sigma_draws(:,keep)=vec(sigma_draw); %reduced form variance covariance
        relevance_draws(1,keep) = bet^2/(bet^2 + signu^2);
        D=zeros(n,n);
        D(:,1)=hsigma*Q;
        D_draws(:,keep)=vec(D);
        if IRFt==5
            [~, ortirfmatrix]=irfsim(beta_draw,hsigma,n,m,p,k,IRFperiods);
            % store
            IV_draws=eye(n,n);
            IV_draws(:,1)=Q;
            for kk=1:IRFperiods
                irf_storage{keep,1}(:,:,kk)=ortirfmatrix(:,:,kk)*IV_draws; %rotated orthogonal IRFs
            end
            Etatemp=D\EPS_draw';
            for kkk=2:n
               for tt=1:size(Etatemp,2)
                       Etatemp(kkk,tt)=0;
               end 
            end
            ETA_storage{keep,1}=Etatemp;
            gamma_draws(:,keep)=vec(eye(n,n));
        elseif IRFt==6
        IV_draws(:,keep)=Q;
        C_draws(:,keep)=vec(hsigma);
        end
        end
        end
        
        hbar.iterate(1); % update progress by one iteration 
end
close(hbar);   %close progress bar

%compute relevance
median_relevance = median(relevance_draws);
% print accepted draws in command window and results file
filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'at');


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n',['Total Number of Draws: ', num2str(AA)]);
fprintf(fid,'%s\n',['Total Number of Draws: ', num2str(AA)]);
fprintf('%s\n',['Reduced form acceptance rate: ', num2str(acpt_reduced_form/AA)]);
fprintf(fid,'%s\n',['Reduced form acceptance rate: ', num2str(acpt_reduced_form/AA)]);
fprintf('%s\n',['Rotation Matrix acceptance rate: ', num2str(acpt_Q/AA)]);
fprintf(fid,'%s\n',['Rotation Matrix acceptance rate: ', num2str(acpt_Q/AA)]);
fprintf('%s\n',['Median relevance of the proxy: ', num2str(median_relevance)]);
fprintf(fid,'%s\n',['Median relevance of the proxy: ', num2str(median_relevance)]);
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fclose(fid);