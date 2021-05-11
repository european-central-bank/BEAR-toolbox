function [beta_gibbs,F_gibbs,L_gibbs,phi_gibbs,sigma_gibbs,lambda_t_gibbs,sigma_t_gibbs,sbar,favar,It,Bu]=...
    favar_stvol3gibbs(Xbart,Xt,yt,B0,phi0,alpha0,delta0,f0,upsilon0,betahat,sigmahat,gamma,G,I_o,omega,T,n,k,It,Bu,pick,pickf,favar,data_endo,lags)

%% preliminaries
% initialise variables
nfactorvar=favar.nfactorvar;
numpc=favar.numpc;
favarX=favar.X(:,favar.plotX_index);
onestep=favar.onestep;
Sigma=nspd(favar.Sigma);
Ll=favar.L;
favar_X=favar.X;
% load priors
L0=favar.L0*eye(n);
a0=favar.a0;
b0=favar.b0;
% sigmahat=(1/T)*(EPS'*EPS);

% preallocation
Ll_gibbs=zeros(size(Ll(:),1),It-Bu);
R2_gibbs=zeros(size(favarX,2),It-Bu);

if onestep==0 %static factors in this case
    FY=data_endo;
    pbstring='two-step'; %string for the progress bar
    % elseif onestep==1
    %     pbstring='one-step'; %string for the progress bar
end


% preliminary elements for the algorithm
% compute the product G'*I_gamma*G (to speed up computations of deltabar)
GIG=G'*I_o*G;
% compute alphabar
alphabar=T+alpha0;



% initiate the Gibbs sampler
% initiate the counting of iterations
count=1;
pickcount=1;
% initiate the record matrices and cells
beta_gibbs=[];
F_gibbs=[];
L_gibbs=[];
phi_gibbs=[];
sigma_gibbs=[];
lambda_t_gibbs={};
sigma_t_gibbs={};



% step 1: determine initial values for the algorithm

% initial value for beta
beta=betahat;
B=reshape(beta,k,n);
% initial value for f_2,...,f_n
% obtain the triangular factorisation of sigmahat
[Fhat Lambdahat]=triangf(sigmahat);
% obtain the initial value for F
F=Fhat;
% obtain the inverse of Fhat
[invFhat]=invltod(Fhat,n);
% create the cell storing the different vectors of invF
Finv=cell(n,1);
% store the vectors
for ii=2:n
    Finv{ii,1}=invFhat(ii,1:ii-1);
end
% initial values for L
L=zeros(T,1);
% initial values for phi
phi=1;



% step 2: determine the sbar values and Lambda
sbar=diag(Lambdahat);
Lambda=sparse(diag(sbar));
% then determine sigma^(0)
sigma=F*Lambda*F';


% step 3: recover the series of initial values for lambda_1,...,lambda_T and sigma_1,...,sigma_T
lambda_t=repmat(diag(sbar),1,1,T);
sigma_t=repmat(sigmahat,1,1,T);

% create a progress bar
hbar = parfor_progressbar(It,['Progress of the Gibbs sampler (',pbstring,').']);

%% run the Gibbs sampler
while count<=It
    
    % step 4: draw beta from its conditional posterior
    % first compute the summations required for omegabar and betabar
    summ1=zeros(k,k);
    summ2=zeros(k,n);
    % run the summation
    for jj=1:T
        prodt=Xt{jj,1}'*exp(-L(jj,1));
        summ1=summ1+prodt*Xt{jj,1};
        summ2=summ2+prodt*yt(:,:,jj)';
    end
    % then obtain the inverse of phi0
    invphi0=diag(1./diag(phi0));
    % obtain the inverse of phibar
    invphibar=summ1+invphi0;
    % recover phibar
    C=chol(nspd(invphibar),'Lower')';
    invC=C\speye(k);
    phibar=invC*invC';
    % recover Bbar
    Bbar=phibar*(summ2+invphi0*B0);
    % draw B from its posterior
    B=matrixndraw(Bbar,sigma,phibar,k,n);
    % finally recover beta by vectorising
    beta=B(:);
    
    
    % step 5: draw the series f_2,...,f_n from their conditional posteriors
    % recover first the residuals
    for jj=1:T
        epst(:,:,jj)=yt(:,:,jj)-Xbart{jj,1}*beta;
    end
    % then draw the vectors in turn
    for jj=2:n
        % first compute the summations required for upsilonbar and fbar
        summ1=zeros(jj-1,jj-1);
        summ2=zeros(jj-1,1);
        % run the summation
        for kk=1:T
            prodt=epst(1:jj-1,1,kk)*exp(-L(kk,1));
            summ1=summ1+prodt*epst(1:jj-1,1,kk)';
            summ2=summ2+prodt*epst(jj,1,kk)';
        end
        summ1=(1/sbar(jj,1))*summ1;
        summ2=(-1/sbar(jj,1))*summ2;
        % then obtain the inverse of upsilon0
        invupsilon0=diag(1./diag(upsilon0{jj,1}));
        % obtain upsilonbar
        invupsilonbar=summ1+invupsilon0;
        C=chol(nspd(invupsilonbar));
        invC=C\speye(jj-1);
        upsilonbar=full(invC*invC');
        % recover fbar
        fbar=upsilonbar*(summ2+invupsilon0*f0{jj,1});
        % finally draw f_i^(-1)
        Finv{jj,1}=fbar+chol(nspd(upsilonbar),'lower')*randn(jj-1,1);
    end
    % recover the inverse of F
    invF=eye(n);
    for jj=2:n
        invF(jj,1:jj-1)=Finv{jj,1};
    end
    % eventually recover F
    F=invltod(invF,n);
    % update sigma
    sigma=F*Lambda*F';
    
    % step 6: draw phi from its conditional posterior
    % estimate deltabar
    deltabar=L'*GIG*L+delta0;
    % draw the value phi_i
    phi=igrandn(alphabar/2,deltabar/2);
    
    % step 7: draw the series lambda_t from their conditional posteriors, t=1,...,T
    % consider periods in turn
    for kk=1:T
        % a candidate value will be drawn from N(lambdabar,phibar)
        % the definitions of lambdabar and phibar varies with the period, thus define them first
        % if the period is the first period
        if kk==1
            lambdabar=(gamma*L(2,1))/(1/omega+gamma^2);
            phibar=phi/(1/omega+gamma^2);
            % if the period is the final period
        elseif kk==T
            lambdabar=gamma*L(T-1,1);
            phibar=phi;
            % if the period is any period in-between
        else
            lambdabar=(gamma/(1+gamma^2))*(L(kk-1,1)+L(kk+1,1));
            phibar=phi/(1+gamma^2);
        end
        % now draw the candidate
        cand=lambdabar+phibar^0.5*randn;
        % compute the acceptance probability
        prob=mhprob3(cand,L(kk,1),sbar,epst(:,1,kk),Finv,n);
        % draw a uniform random number
        draw=rand;
        % keep the candidate if the draw value is lower than the prob
        if draw<=prob
            L(kk,1)=cand;
            % if not, just keep the former value
        end
    end
    % then recover the series of matrices lambda_t and sigma_t
    for kk=1:T
        lambda_t(:,:,kk)=exp(L(kk,1))*diag(sbar);
        sigma_t(:,:,kk)=F*lambda_t(:,:,kk)*F';
    end
    
    %% Sample Sigma and Ll (static)
    [Sigma,Ll]=favar_SigmaL(Sigma,Ll,nfactorvar,numpc,onestep,n,favar_X,FY,a0,b0,T,lags,L0);
    
    %% record phase
    % if the burn-in sample phase is not yet over
    if count<=Bu
        % simply add 1 to the iteration count
        count=count+1;
        % on the other hand, if the burn-in sample phase is over
    elseif count>Bu
        % adding one iteration to the count will depend on wether post-burn selection applies
        % if there is no post burn selection
        if pick==0
            % record the results
            beta_gibbs(:,count-Bu)=beta;
            F_gibbs(:,:,count-Bu)=F;
            L_gibbs(:,:,count-Bu)=L;
            phi_gibbs(count-Bu,1)=phi;
            sigma_gibbs(:,count-Bu)=sigma(:);
            % save the factors and loadings (keep the notation in the code consistent, although - except L - they don't change)
            Ll_gibbs(:,count-Bu)=Ll(:);
            
            % compute R2 (Coefficient of Determination) for plotX variables (keep the notation in the code consistent, although they don't change)
            R2=favar_R2(favarX,FY);
            R2_gibbs(:,count-Bu)=R2(:);
            for jj=1:T
                lambda_t_gibbs{jj,1}(:,:,count-Bu)=lambda_t(:,:,jj);
                sigma_t_gibbs{jj,1}(:,:,count-Bu)=sigma_t(:,:,jj);
            end
            % then add one to the count
            count=count+1;
            % if there is post burn selection, only one draw over 'fpick' draws will be retained
        elseif pick==1
            % if the iteration does not correspond to fpick, don't record the results, don't increase the regular count, but do increase pickcount by 1, and do record the acceptance rate of the Metropolis-Hastings step
            if pickcount~=pickf
                pickcount=pickcount+1;
                % on the other hand, if the iteration does correspond to fpick
            elseif pickcount==pickf
                % do record the results
                beta_gibbs(:,count-Bu)=beta;
                F_gibbs(:,:,count-Bu)=F;
                L_gibbs(:,:,count-Bu)=L;
                phi_gibbs(count-Bu,1)=phi;
                sigma_gibbs(:,count-Bu)=sigma(:);
                % save the factors and loadings (keep the notation in the code consistent, although - except L - they don't change)
                Ll_gibbs(:,count-Bu)=Ll(:);
                
                % compute R2 (Coefficient of Determination) for plotX variables (keep the notation in the code consistent, although they don't change)
                R2=favar_R2(favarX,FY);
                R2_gibbs(:,count-Bu)=R2(:);
                for jj=1:T
                    lambda_t_gibbs{jj,1}(:,:,count-Bu)=lambda_t(:,:,jj);
                    sigma_t_gibbs{jj,1}(:,:,count-Bu)=sigma_t(:,:,jj);
                end
                % then increase the regular count by 1 and re-initialise pickcount
                count=count+1;
                pickcount=1;
            end
        end
    end
    
    % update progress by one iteration
    hbar.iterate(1);
    
end

% in case we have thinning of the draws,
thin=abs(round(favar.thin)); % should be a positive integer
if thin~=1
    beta_gibbs=beta_gibbs(:,thin:thin:end);
    F_gibbs=F_gibbs(:,thin:thin:end);
    L_gibbs=L_gibbs(:,thin:thin:end);
    phi_gibbs=phi_gibbs(:,thin:thin:end);
    sigma_gibbs=sigma_gibbs(:,thin:thin:end);
    Ll_gibbs=Ll_gibbs(:,thin:thin:end);
    R2_gibbs=R2_gibbs(:,thin:thin:end);
    for jj=1:T
        lambda_t_gibbs=lambda_t_gibbs(:,:,thin:thin:end);
        sigma_t_gibbs=sigma_t_gibbs(:,:,thin:thin:end);
    end
    It=(1/thin)*It;
    Bu=(1/thin)*Bu;
end

% save in favar structure
favar.L_gibbs=Ll_gibbs;
favar.R2_gibbs=R2_gibbs;

close(hbar);   %close progress bar

