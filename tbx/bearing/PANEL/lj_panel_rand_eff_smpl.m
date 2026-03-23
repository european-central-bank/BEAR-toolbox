function outSampler = lj_panel_rand_eff_smpl(this, meta, longYXZ)

    % input
    % meta - model specific meta parameters
    % longY - matrix with endogenous variables (whole sample)
    % longX - matrix with exogenous variables (whole sample)
    % longZ - matrix with reducibles (whole sample, used for factor models)

    % output
    % outSampler - sampler function
    
    const = meta.flagConst;
    lags  = meta.numLags;

    lambda1 = this.Settings.lambda1;

    [longY, longX, ~] = longYXZ{:};

    % compute preliminary elements
    [~, Xibar, Xbar, ~, yi, y, N, n, ~, ~, ~, ~, q, h]=bear.panel3prelim(longY,longX,const,lags);

    % obtain prior elements
    [~, bbar, sigeps]=bear.panel3prior(Xibar,Xbar,yi,y,N,q);

    % compute posterior distribution parameters
    [omegabarb, betabar]=bear.panel3post(h,Xbar,y,lambda1,bbar,sigeps);
    
    % sampler will be a function
    function smpl = sampler()

        % draw a random vector beta from N(betabar,omegabarb)
        % TODO - optimize chol (can be run only once)
        beta=betabar+chol(bear.nspd(omegabarb),'lower')*mvnrnd(zeros(h,1),eye(h))';

        beta=reshape(beta,q,N);
        % record values by marginalising over each unit
        for jj=1:N

            beta_gibbs(:,jj)=beta(:,jj);

        end

        % obtain a record of draws for sigma, the residual variance-covariance matrix
        % compute sigma
        sigma=sigeps*eye(n);

        sigma_gibbs=repmat(sigma(:),[1 N]);
        
        smpl = struct();
        smpl.beta = beta_gibbs;
        smpl.sigma = sigma_gibbs;

    end

    outSampler = @sampler;
end