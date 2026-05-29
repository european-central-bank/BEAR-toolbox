function outSampler = lj_panel_ols_smpl(this, meta, longYXZ)

    % output
    % outSampler - sampler function
    
    const = meta.flagConst;
    lags  = meta.numLags;

    [longY, longX, ~] = longYXZ{:};

    % compute preliminary elements
    [X, Y, N, n, m, p, T, k, q]=bear.panel1prelim(longY,longX,const,lags);

    % obtain the estimates for the model
    [bhat, sigmahatb, sigmahat]=bear.panel1estimates(X,Y,N,n,q,k,T);
    
    % sampler will be a function
    function smpl = sampler()
      
      % draw a random vector beta from its distribution
      % if the produced VAR model is not stationary, draw another vector, and keep drawing till a stationary VAR is obtained
      stationary = 0;

      while stationary==0
        
        beta=bhat+chol(bear.nspd(sigmahatb),'lower')*randn(q,1);

        [stationary,~]=bear.checkstable(beta,n,p,k);

      end

      smpl = struct();
      smpl.beta = beta;
      smpl.sigma = sigmahat;
      smpl.bhat = bhat;

    end

    outSampler = @sampler;
end