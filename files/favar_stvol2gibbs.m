function [beta_gibbs,F_gibbs,gamma_gibbs,L_gibbs,phi_gibbs,sigma_gibbs,lambda_t_gibbs,sigma_t_gibbs,sbar,favar,It,Bu]=...
    favar_stvol2gibbs(Xbart,yt,beta0,omega0,alpha0,delta0,gamma0,zeta0,f0,upsilon0,betahat,sigmahat,I_o,omega,T,n,q,It,Bu,pick,pickf,favar,data_endo,lags)

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
% initial value for f_2,...,f_n
% obtain the triangular factorisation of sigmahat
[Fhat,Lambdahat]=triangf(sigmahat);
% obtain the inverse of Fhat
[invFhat]=invltod(Fhat,n);
% create the cell storing the different vectors of invF
Finv=cell(n,1);
% store the vectors
for ii=2:n
    Finv{ii,1}=invFhat(ii,1:ii-1);
end
% initial values for L_1,...,L_n
L=zeros(T,n);
% initial values for gamma_1,...,gamma_n
gamma=0.85*ones(1,n);
% initial values for G_1,...,G_n
G=cell(n,1);
for ii=1:n
    G{ii,1}=speye(T)-sparse(diag(gamma(1,ii)*ones(T-1,1),-1));
end
% initial values for phi_1,...,phi_n
phi=ones(1,n);

% step 2: determine the sbar values and Lambda
sbar=diag(Lambdahat);
Lambda=sparse(diag(sbar));

% step 3: recover the series of initial values for lambda_1,...,lambda_T and sigma_1,...,sigma_T
lambda_t=repmat(diag(sbar),1,1,T);
sigma_t=repmat(sigmahat,1,1,T);

% create a progress bar
hbar = parfor_progressbar(It,['Progress of the Gibbs sampler (',pbstring,').']);

%% run the Gibbs sampler
while count<=It
    
    % step 4: draw beta from its conditional posterior
    % first compute the summations required for omegabar and betabar
    summ1=zeros(q,q);
    summ2=zeros(q,1);
    % run the summation
    for jj=1:T
        prodt=Xbart{jj,1}'/sigma_t(:,:,jj);
        summ1=summ1+prodt*Xbart{jj,1};
        summ2=summ2+prodt*yt(:,:,jj);
    end
    % then obtain the inverse of omega0
    invomega0=diag(1./diag(omega0));
    % obtain the inverse of omegabar
    invomegabar=summ1+invomega0;
    % recover omegabar
    C=chol(nspd(invomegabar),'Lower')';
    invC=C\speye(q);
    omegabar=invC*invC';
    % recover betabar
    betabar=omegabar*(summ2+invomega0*beta0);
    % finally, draw beta from its posterior
    beta=betabar+chol(nspd(omegabar),'lower')*randn(q,1);
    
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
            prodt=epst(1:jj-1,1,kk)*exp(-L(kk,jj));
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
    % then update sigma
    sigma=F*Lambda*F';
    
    % step 6: draw the series gamma_1,...,gamma_n from their conditional posteriors
    % draw the parameters in turn
    for jj=1:n
        % estimate zetabar
        zetabar=1/((1/phi(1,jj))*L(1:T-1,jj)'*L(1:T-1,jj)+1/zeta0);
        % estimate zetabar
        gammabar=zetabar*((1/phi(1,jj))*L(2:T,jj)'*L(1:T-1,jj)+gamma0/zeta0);
        % draw the value gamma_i
        gamma(1,jj)=gammabar+zetabar^0.5*randn;
        % obtain G_i
        G{jj,1}=speye(T)-sparse(diag(gamma(1,jj)*ones(T-1,1),-1));
    end
    
    % step 7: draw the series phi_1,...,phi_n from their conditional posteriors
    % draw the parameters in turn
    for jj=1:n
        % estimate deltabar
        deltabar=L(:,jj)'*G{jj,1}'*I_o*G{jj,1}*L(:,jj)+delta0;
        % draw the value phi_i
        phi(1,jj)=igrandn(alphabar/2,deltabar/2);
    end
    
    % step 8: draw the series lambda_i,t from their conditional posteriors, i=1,...,n and t=1,...,T
    % consider variables in turn
    for jj=1:n
        % consider periods in turn
        for kk=1:T
            % a candidate value will be drawn from N(lambdabar,phibar)
            % the definitions of lambdabar and phibar varies with the period, thus define them first
            % if the period is the first period
            if kk==1
                lambdabar=(gamma(1,jj)*L(2,jj))/(1/omega+gamma(1,jj)^2);
                phibar=phi(1,jj)/(1/omega+gamma(1,jj)^2);
                % if the period is the final period
            elseif kk==T
                lambdabar=gamma(1,jj)*L(T-1,jj);
                phibar=phi(1,jj);
                % if the period is any period in-between
            else
                lambdabar=(gamma(1,jj)/(1+gamma(1,jj)^2))*(L(kk-1,jj)+L(kk+1,jj));
                phibar=phi(1,jj)/(1+gamma(1,jj)^2);
            end
            % now draw the candidate
            cand=lambdabar+phibar^0.5*randn;
            % compute the acceptance probability
            prob=mhprob2(jj,cand,L(kk,jj),sbar(jj,1),epst(:,1,kk),Finv{jj,1});
            % draw a uniform random number
            draw=rand;
            % keep the candidate if the draw value is lower than the prob
            if draw<=prob
                L(kk,jj)=cand;
                % if not, just keep the former value
            end
        end
    end
    % then recover the series of matrices lambda_t and sigma_t
    for jj=1:T
        lambda_t(:,:,jj)=diag(sbar).*diag(exp(L(jj,:)));
        sigma_t(:,:,jj)=F*lambda_t(:,:,jj)*F';
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
            gamma_gibbs(count-Bu,:)=gamma;
            L_gibbs(:,:,count-Bu)=L;
            phi_gibbs(count-Bu,:)=phi;
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
                gamma_gibbs(count-Bu,:)=gamma;
                L_gibbs(:,:,count-Bu)=L;
                phi_gibbs(count-Bu,:)=phi;
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

