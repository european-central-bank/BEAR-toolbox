function outSampler = lj_panel_bayesian_smpl(this, meta, longYXZ)

    % input
    % meta - model specific meta parameters
    % longY - matrix with endogenous variables (whole sample)
    % longX - matrix with exogenous variables (whole sample)
    % longZ - matrix with reducibles (whole sample, used for factor models)

    % output
    % outSampler - sampler function
    
    const = meta.flagConst;
    lags  = meta.numLags;
    numCountries = meta.numCountries;

    lambda1 = this.Settings.lambda1;
    lambda3 = this.Settings.lambda3;
    lambda4 = this.Settings.lambda4;
    ar = this.Settings.ar;
    priorexo = this.Settings.priorexo;

    [longY, longX, ~] = longYXZ{:};

    % compute preliminary elements
    [X, ~, Y, ~, N, n, m, p, T, k, q]=bear.panel2prelim(longY,longX,const,lags,cell(numCountries,1));

    % obtain prior elements (from a standard normal-Wishart)
    [B0, beta0, phi0, S0, alpha0]=bear.panel2prior(N,n,m,p,T,k,q,longY,ar,lambda1,lambda3,lambda4,priorexo);

    % obtain posterior distribution parameters
    [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,N*T,k);
    
    % sampler will be a function
    function smpl = sampler()

        % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
        B=bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);

        % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
        sigma=bear.iwdraw(Sbar,alphabar);
        
        smpl = struct();
        smpl.beta = B(:);
        smpl.sigma = sigma(:);

    end

    outSampler = @sampler;
end