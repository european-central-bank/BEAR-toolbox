
function outSampler = adapterSampler(this, YXZ)

    arguments
        this
        YXZ (1, 3) cell
    end

    [Y_long, X_long, ~] = YXZ{:};

    opt.const = this.Settings.HasConstant;
    opt.lags = this.Settings.Order;   
    
    opt.user_ar = this.Settings.Autoregression;
    opt.lambda1 = this.Settings.Lambda1;
    opt.lambda2 = this.Settings.Lambda2;    
    opt.lambda3 = this.Settings.Lambda3;
    opt.lambda4 = this.Settings.Lambda4;
    opt.lambda5 = this.Settings.Lambda5;
    opt.priorsexogenous = this.Settings.Exogenous;


    opt.alpha0 = this.Settings.alpha0;
    opt.delta0 = this.Settings.delta0;
    opt.gamma = this.Settings.gamma;

    [~, betahat, sigmahat, X, ~, Y, ~, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = ...
        bear.olsvar(Y_long, X_long, opt.const, opt.lags);

    [arvar]  =  bear.arloop(data_endo_a, opt.const, p, numEn);
    ar  =  ones(numEn,1)*opt.user_ar;

    if numEx > 0
    % individual priors 0 for default
        for ii = 1:numEn
            for jj = 1:numEx
                priorexo(ii, jj)  =  opt.priorsexogenous;
                tmp(ii, jj)  =  opt.lambda4;
            end
        end
    opt.lambda4  =  tmp;    
    else
        for ii = 1:numEn
            priorexo(ii, 1)  =  opt.priorsexogenous;
        end
    end
    
    %create matrices
    [yt, Xt, Xbart]  =  bear.stvoltmat(Y, X, numEn, estimLength); %create TV matrices
    [B0, phi0, G, I_o, omega, f0, upsilon0] = bear.stvol3prior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, ...
        numEn, numEx, p, estimLength, numBRows, sizeB, opt.gamma, priorexo);

    % preliminary elements for the algorithm
    % compute the product G' * I_gamma * G (to speed up computations of deltabar)
    GIG = G' * I_o * G;
    
    % compute alphabar
    alphabar = estimLength + alpha0;


    % step 1: determine initial values for the algorithm

    % initial value for beta
    beta = betahat;

    B = reshape(beta, numBRow, numEn);

    % initial value for f_2, ..., f_n
    % obtain the triangular factorisation of sigmahat
    [Fhat,  Lambdahat] = bear.triangf(sigmahat);

    % obtain the initial value for F
    F = Fhat;

    % obtain the inverse of Fhat
    [invFhat] = bear.invltod(Fhat, numEn);

    % create the cell storing the different vectors of invF
    Finv = cell(numEn, 1);
    
    % store the vectors
    for ii = 2:numEn
        Finv{ii, 1} = invFhat(ii, 1:ii - 1);
    end

    % initial values for L
    L = zeros(estimLength, 1);
    
    % initial values for phi
    phi = 1;

    % step 2: determine the sbar values and Lambda
    sbar = diag(Lambdahat);
    Lambda = sparse(diag(sbar));

    % then determine sigma^(0)
    sigma = F * Lambda * F';


    % step 3: recover the series of initial values for lambda_1, ..., lambda_T and sigma_1, ..., sigma_T
    lambda_t = repmat(diag(sbar), 1, 1, estimLength);
    sigma_t  =  repmat(sigmahat, 1, 1, estimLength);

    function sampleStruct  =  sampler()

        summ1 = zeros(numBRows, numBRows);
        summ2 = zeros(numBRows, numEn);

        % run the summation
        for zz = 1:T
            prodt = Xt{zz, 1}' * exp( -L(zz, 1));
            summ1 = summ1 + prodt * Xt{zz, 1};
            summ2 = summ2 + prodt * yt(:, :, zz)';
        end

        % then obtain the inverse of phi0
        invphi0 = diag(1. / diag(phi0));

        % obtain the inverse of phibar
        invphibar = summ1 + invphi0;

        % recover phibar
        C = chol(bear.nspd(invphibar), 'Lower')';
        invC = C \ speye(numBRows);
        phibar = invC * invC';

        % recover Bbar
        Bbar = phibar * (summ2 + invphi0 * B0);

        % draw B from its posterior
        B = bear.matrixndraw(Bbar, sigma, phibar, numBRows, numEn);

        % finally recover beta by vectorising
        beta = B(:);

        % step 5: draw the series f_2, ..., f_n from their conditional posteriors
        % recover first the residuals
        for zz = 1:T
            epst(:, :, zz) = yt(:, :, zz) - Xbart{zz, 1} * beta;
        end

        % then draw the vectors in turn
        for zz = 2:numEn
            % first compute the summations required for upsilonbar and fbar
            summ1 = zeros(zz - 1, zz - 1);
            summ2 = zeros(zz - 1, 1);

            % run the summation
            for kk = 1:T
                prodt = epst(1:zz - 1, 1, kk) * exp( -L(kk, 1));
                summ1 = summ1 + prodt * epst(1:zz - 1, 1, kk)';
                summ2 = summ2 + prodt * epst(zz, 1, kk)';
            end

            summ1 = (1 / sbar(zz, 1)) * summ1;
            summ2 = ( - 1 / sbar(zz, 1)) * summ2;

            % then obtain the inverse of upsilon0
            invupsilon0 = diag(1. / diag(upsilon0{zz, 1}));

            % obtain upsilonbar
            invupsilonbar = summ1 + invupsilon0;
            C = chol(bear.nspd(invupsilonbar));
            invC = C \ speye(zz - 1);
            upsilonbar = full(invC * invC');

            % recover fbar
            fbar = upsilonbar * (summ2 + invupsilon0 * f0{zz, 1});

            % finally draw f_i^( - 1)
            Finv{zz, 1} = fbar + chol(bear.nspd(upsilonbar), 'lower') * randn(zz - 1, 1);
        end

        % recover the inverse of F
        invF = eye(numEn);
        for zz = 2:numEn
            invF(zz, 1:zz - 1) = Finv{zz, 1};
        end

        % eventually recover F
        F = bear.invltod(invF, numEn);

        % update sigma
        sigma = F * Lambda * F';


        % step 6: draw phi from its conditional posterior
        % estimate deltabar
        deltabar = L' * GIG * L + delta0;

        % draw the value phi_i
        phi = bear.igrandn(alphabar / 2, deltabar / 2);


        % step 7: draw the series lambda_t from their conditional posteriors,  t = 1, ..., T
        % consider periods in turn
        for kk = 1:T
            % a candidate value will be drawn from N(lambdabar, phibar)
            % the definitions of lambdabar and phibar varies with the period,  thus define them first
            % if the period is the first period
            if kk == 1
                lambdabar = (opt.gamma * L(2, 1)) / (1 / omega + opt.gamma^2);
                phibar = phi / (1 / omega + opt.gamma^2);
        
                % if the period is the final period
            elseif kk == T
                lambdabar = opt.gamma * L(T - 1, 1);
                phibar = phi;
                
                % if the period is any period in - between
            else
                lambdabar = (opt.gamma / (1 + opt.gamma^2)) * (L(kk - 1, 1) + L(kk + 1, 1));
                phibar = phi / (1 + opt.gamma^2);
            end

            % now draw the candidate
            cand = lambdabar + phibar^0.5 * randn;

            % compute the acceptance probability
            prob = bear.mhprob3(cand, L(kk, 1), sbar, epst(:, 1, kk), Finv, numEn);

            % draw a uniform random number
            draw = rand;

            % keep the candidate if the draw value is lower than the prob
            if draw <= prob
                L(kk, 1) = cand;
                % if not,  just keep the former value
            end
        end

        % then recover the series of matrices lambda_t and sigma_t
        for kk = 1:T
            lambda_t(:, :, kk) = exp(L(kk, 1)) * diag(sbar);
            sigma_t(:, :, kk) = F * lambda_t(:, :, kk) * F';
        end
        
        sampleStruct.beta = beta;
        sampleStruct.F = F;
        sampleStruct.L = mat2cell(L, ones(estimLength, 1), numEn);
        sampleStruct.phi = phi;
        sampleStruct.sigma_avg = sigma(:);


        for zz = 1:estimLength
            sampleStruct.lambda_t_gibbs{zz, 1} = lambda_t(:, :, zz);
            sampleStruct.sigma_t_gibbs{zz, 1} = sigma_t(:, :, zz);
        end  
        
    end 

    outSampler = @sampler;

end

