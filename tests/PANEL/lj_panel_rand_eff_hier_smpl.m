function outSampler = lj_panel_rand_eff_hier_smpl(this, meta, longYXZ)

    % input
    % meta - model specific meta parameters
    % hyper - model specific hyper parameters
    % longY - matrix with endogenous variables (whole sample)
    % longX - matrix with exogenous variables (whole sample)
    % longZ - matrix with reducibles (whole sample, used for factor models)

    % output
    % outSampler - sampler function
    
    const = meta.flagConst;
    lags  = meta.numLags;

    lambda2 = this.Settings.lambda2;
    lambda3 = this.Settings.lambda3;
    lambda4 = this.Settings.lambda4;
    s0 = this.Settings.s0;
    v0 = this.Settings.v0;
    Bu = this.Settings.Bu;

    [longY, longX, ~] = longYXZ{:};

    % compute preliminary elements
    [Xi, ~, ~, Yi, ~, ~, numCountries, numEndog, numExog, numLags, T, ~, ~, ~]=bear.panel4prelim(longY,longX,const,lags);

    % determine k, the number of parameters to estimate in each equation
    k=numEndog*numLags+numExog;

    % determine q, the total number of VAR parameters for each country
    q=numEndog*k;

    % determine h, the total number of VAR parameters for the whole model
    h=numCountries*q;

    % obtain prior elements
    [omegab]=bear.panel4prior(numCountries,numEndog,numExog,numLags,T,k,data_endo,q,lambda3,lambda2,lambda4);

    % compute first  preliminary elements
    % compute sbar
    sbar=h+s0;

    % compute the inverse of omegab
    invomegab=diag(1./diag(omegab));

    % step 1: compute initial values
    % initial value for beta (use OLS values)
    for ii=1:numCountries

        beta_init(:,ii)=bear.vec((Xi(:,:,ii)'*Xi(:,:,ii))\(Xi(:,:,ii)'*Yi(:,:,ii)));

    end

    % initial value for b
    % Actually not used!!!
    b=(1/numCountries)*sum(beta_init,2);

    % initial value for lambda1
    lambda1=0.01;
    sigmab=lambda1*omegab;

    % initial value for sigma (use OLS values)
    for ii=1:numCountries

        eps=Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta_init(:,ii),k,numEndog);

        sigma(:,:,ii)=(1/(T-k-1))*eps'*eps;

    end

    beta = beta_init;

    % sampler will be a function
    function smpl = sampler()

        % step 2: obtain b
        % first compute betam, the mean value of the betas over all units
        betam=(1/numCountries)*sum(beta,2);

        % draw b from a multivariate normal N(betam,(1/numCountries)*sigmab))
        b=betam+chol(bear.nspd((1/numCountries)*sigmab),'lower')*mvnrnd(zeros(q,1),eye(q))';

        % step 3: obtain sigmab
        % compute first vbar
        for ii=1:numCountries

            temp(1,ii)=(beta(:,ii)-b)'*invomegab*(beta(:,ii)-b);

        end

        vbar=v0+sum(temp,2);

        % compute lambda1
        lambda1=bear.igrandn(sbar/2,vbar/2);

        % recover sigmab
        sigmab=lambda1*omegab;

        % step 4: draw the series of betas
        % first obtain the inverse of sigmab
        invsigmab=diag(1./diag(sigmab));
        
        % then loop over units
        for ii=1:numCountries

            % take the choleski factor of sigma of unit ii, inverse it, and obtain from it the inverse of the original sigma
            C=bear.trns(chol(bear.nspd(sigma(:,:,ii)),'Lower'));

            invC=C\speye(numEndog);

            invsigma=invC*invC';

            % obtain omegabar
            invomegabar=kron(invsigma,Xi(:,:,ii)'*Xi(:,:,ii))+invsigmab;

            % invert
            C=bear.trns(chol(bear.nspd(invomegabar),'Lower'));

            invC=C\speye(q);
            
            omegabar=invC*invC';

            % obtain betabar
            betabar=omegabar*(kron(invsigma,Xi(:,:,ii)')*bear.vec(Yi(:,:,ii))+invsigmab*b);

            % draw beta
            beta(:,ii)=betabar+chol(bear.nspd(omegabar),'lower')*mvnrnd(zeros(q,1),eye(q))';

            beta_gibbs(:,ii)=beta(:,ii);

        end

        % step 5: draw the series of sigmas
        % loop over units
        for ii=1:numCountries

            % compute Stilde
            Stilde=(Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,numEndog))'*(Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,numEndog));

            % draw sigma
            sigma(:,:,ii)=bear.iwdraw(Stilde,T);

            sigma_gibbs(:,ii)=bear.vec(sigma(:,:,ii));

        end

        beta_mean=b;

        sigma_mean=bear.vec(mean(sigma,3));

        lambda_posterior=lambda1;

        % store sample results
        smpl = struct();
        smpl.beta = beta_gibbs;
        smpl.sigma = sigma_gibbs;
      
    end

    % Burning part before returning the sampler
    for count=1:Bu
        sampler();
    end

    outSampler = @sampler;
end