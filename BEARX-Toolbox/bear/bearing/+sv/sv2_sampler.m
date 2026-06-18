
function outSampler = adapterSampler(this, YXZ)

    arguments
        this
        YXZ (1, 3) cell
    end

    [Y_long, X_long, ~] = YXZ{:};

    opt.const = this.Settings.HasConstant;
    opt.lags = this.Settings.Order;  
    opt.lambda1 = this.Settings.Lambda1;
    opt.lambda2 = this.Settings.Lambda2;    
    opt.lambda3 = this.Settings.Lambda3;
    opt.lambda4 = this.Settings.Lambda4;
    opt.lambda5 = this.Settings.Lambda5; 
    opt.priorsexogenous = this.Settings.Exogenous;

    opt.alpha0 = this.Settings.alpha0;
    opt.delta0 = this.Settings.delta0;
    opt.gamma0 = this.Settings.gamma0;
    opt.zeta0 = this.Settings.zeta0;

    [~, betahat, sigmahat, X, ~, Y, ~, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = ...
        bear.olsvar(Y_long, X_long, opt.const, opt.lags);

    [arvar]  =  bear.arloop(Y_long, opt.const, p, numEn);

    blockexo  =  [];
    if  opt.bex == 1
        [blockexo] = bear.loadbex(endo, pref);
    end
    
    %create matrices
    [yt, ~, Xbart]  =  bear.stvoltmat(Y, X, numEn, estimLength); %create TV matrices
    [beta0, omega0, I_o, omega, f0, upsilon0] = bear.stvol2prior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3,...
        opt.lambda4, opt.lambda5, numEn, numEx, p, estimLength, numBRows, sizeB, opt.bex, blockexo, priorexo);

    alphabar = estimLength + opt.alpha0;

    % initial value for beta
    beta = betahat;
    
    % initial value for f_2,...,f_n
    % obtain the triangular factorisation of sigmahat
    [Fhat, Lambdahat] = bear.triangf(sigmahat);
    
    % obtain the inverse of Fhat
    [invFhat] = bear.invltod(Fhat, numEn);
    
    % create the cell storing the different vectors of invF
    Finv = cell(numEn,1);
    
    % store the vectors
    for ii = 2:numEn
        Finv{ii, 1} = invFhat(ii, 1:ii - 1);
    end

    % initial values for L_1,...,L_n
    L = zeros(estimLength, numEn);
    
    % initial values for gamma_1,...,gamma_n
    gamma = 0.85*ones(1,numEn);
    
    % initial values for G_1,...,G_n
    G = cell(numEn, 1);

    for ii = 1:numEn
        G{ii, 1} = speye(estimLength) - sparse(diag(gamma(1, ii)*ones(estimLength - 1, 1), -1));
    end

    % initial values for phi_1,...,phi_n
    phi = ones(1, numEn);
    
    % step 2: determine the sbar values and Lambda
    sbar = diag(Lambdahat);
    Lambda = sparse(diag(sbar));
    
   
    % step 3: recover the series of initial values for lambda_1,...,lambda_T and sigma_1,...,sigma_T
    lambda_t = repmat(diag(sbar), 1, 1, estimLength);
    sigma_t = repmat(sigmahat, 1, 1, estimLength);

    function sampleStruct  =  sampler()
    
        %% draw beta from its conditional posterior
        % first compute the summations required for omegabar and betabar
        summ1 = zeros(sizeB, sizeB);
        summ2 = zeros(sizeB, 1);
        
        % run the summation
        for zz = 1:estimLength
            prodt = Xbart{zz, 1}'/sigma_t(:, :, zz);
            summ1 = summ1 + prodt*Xbart{zz, 1};
            summ2 = summ2 + prodt*yt(:, :, zz);
        end

        % then obtain the inverse of omega0
        invomega0 = diag(1 ./ diag(omega0));
        
        % obtain the inverse of omegabar
        invomegabar = summ1 + invomega0;
        
        % recover omegabar
        C = chol(bear.nspd(invomegabar), 'Lower')';
        invC = C \ speye(sizeB);
        omegabar = invC * invC';
        
        % recover betabar
        betabar = omegabar * (summ2 + invomega0 * beta0);
        
        % finally, draw beta from its posterior
        beta = betabar + chol(bear.nspd(omegabar), 'lower') * randn(sizeB, 1);
        
        %% draw the series f_2,...,f_n from their conditional posteriors
        % recover first the residuals
        for zz = 1:estimLength
            epst(:, :, zz) = yt(:, :, zz) - Xbart{zz, 1} * beta;
        end
       
        % then draw the vectors in turn
        for zz = 2:numEn
            % first compute the summations required for upsilonbar and fbar
            summ1 = zeros(zz - 1, zz - 1);
            summ2 = zeros(zz - 1, 1);
            
            % run the summation
            for kk = 1:estimLength
                prodt = epst(1:zz - 1, 1, kk) * exp(-L(kk, zz));
                summ1 = summ1 + prodt * epst(1:zz - 1, 1, kk)';
                summ2 = summ2 + prodt * epst(zz, 1, kk)';
            end
            
            summ1 = (1/sbar(zz, 1)) * summ1;
            summ2 = (-1/sbar(zz, 1)) * summ2;
            
            % then obtain the inverse of upsilon0
            invupsilon0 = diag(1 ./ diag(upsilon0{zz, 1}));
           
            % obtain upsilonbar
            invupsilonbar = summ1 + invupsilon0;
            C = chol(bear.nspd(invupsilonbar));
            invC = C\speye(zz - 1);
            upsilonbar = full(invC * invC');
           
            % recover fbar
            fbar = upsilonbar*(summ2 + invupsilon0 * f0{zz, 1});
            
            % finally draw f_i^(-1)
            Finv{zz, 1} = fbar + chol(bear.nspd(upsilonbar), 'lower') * randn(zz - 1, 1);
        end

        % recover the inverse of F
        invF = eye(numEn);
        for zz = 2:numEn
            invF(zz, 1:zz - 1) = Finv{zz, 1};
        end
       
        % eventually recover F
        F = bear.invltod(invF, numEn);
    
        % then update sigma
        sigma = F * Lambda * F';
        
       
        %% draw the series gamma_1,...,gamma_n from their conditional posteriors
        % draw the parameters in turn
        for zz = 1:numEn   
            % estimate zetabar
            zetabar = 1 / ((1 / phi(1, zz)) * L(1:estimLength - 1, zz)' * L(1:estimLength - 1, zz) + 1 / opt.zeta0);
        
            % estimate zetabar
            gammabar = zetabar * ((1 / phi(1, zz)) * L(2:estimLength, zz)'*L(1:estimLength - 1, zz) + opt.gamma0 / opt.zeta0);
            
            % draw the value gamma_i
            gamma(1, zz) = gammabar + zetabar^0.5 * randn;
            
            % obtain G_i
            G{zz, 1} = speye(estimLength) - sparse(diag(gamma(1, zz)*ones(estimLength - 1, 1), -1));
        end
        
        
           
        %% draw the series phi_1,...,phi_n from their conditional posteriors
        % draw the parameters in turn
        for zz = 1:numEn
            
           % estimate deltabar
            deltabar = L(:, zz)' * G{zz, 1}' * I_o * G{zz, 1} * L(:, zz) + opt.delta0;
            
            % draw the value phi_i
            phi(1, zz) = bear.igrandn(alphabar / 2, deltabar / 2);
        end
              
        %% draw the series lambda_i,t from their conditional posteriors, i = 1,...,numEn and t = 1,...,estimLength
        % consider variables in turn
        for zz = 1:numEn
          % consider periods in turn
            for kk = 1:estimLength
            % a candidate value will be drawn from N(lambdabar,phibar)
            % the definitions of lambdabar and phibar varies with the period, thus define them first
    
                % if the period is the first period
                if kk == 1
                    lambdabar = (gamma(1, zz) * L(2, zz)) / (1 / omega + gamma(1, zz)^2);
                    phibar = phi(1, zz) / (1 / omega + gamma(1, zz)^2);
             
                % if the period is the final period
                elseif kk == estimLength
                    lambdabar = gamma(1, zz) * L(estimLength - 1, zz);
                    phibar = phi(1, zz);
    
                % if the period is any period in-between
                else
                    lambdabar = (gamma(1, zz)/(1+gamma(1, zz)^2)) * (L(kk - 1, zz) + L(kk + 1, zz));
                    phibar = phi(1, zz) / (1 + gamma(1, zz)^2);
                end
            
                % now draw the candidate
                cand = lambdabar + phibar^0.5 * randn;
                
                % compute the acceptance probability
                prob = bear.mhprob2(zz, cand, L(kk, zz), sbar(zz, 1), epst(:, 1, kk), Finv{zz, 1});
                
                % draw a uniform random number
                draw = rand;
                
                % keep the candidate if the draw value is lower than the prob
                if draw <= prob
                   L(kk, zz) = cand;
                % if not, just keep the former value
                end
            end
        end
        % then recover the series of matrices lambda_t and sigma_t
        for zz = 1:estimLength
            lambda_t(:, :, zz) = diag(sbar) .* diag(exp(L(zz, :)));
            sigma_t(:, :, zz) = F * lambda_t(:, :, zz) * F';
        end
        
        sampleStruct.beta = beta;
        sampleStruct.omega = diag(omega);
        sampleStruct.F = F;
        sampleStruct.L = mat2cell(L, ones(estimLength, 1), numEn);
        sampleStruct.phi = phi;
        sampleStruct.sigma_avg = sigma(:);
        sampleStruct.gamma = gamma;


        for zz = 1:estimLength
            sampleStruct.lambda_t_gibbs{zz, 1} = lambda_t(:, :, zz);
            sampleStruct.sigma_t_gibbs{zz, 1} = sigma_t(:, :, zz);
        end  
        
    end 

    outSampler = @sampler;

end

