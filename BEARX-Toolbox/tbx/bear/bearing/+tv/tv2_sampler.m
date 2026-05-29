
function outSampler = adapterSampler(this, YXZ)

    arguments
        this
        YXZ (1, 3) cell
    end

    [Y_long, X_long, ~] = YXZ{:};

    opt.const = this.Settings.HasConstant;
    opt.lags = this.Settings.Order;   
    opt.gamma = this.Settings.gamma;
    opt.alpha0 = this.Settings.alpha0;
    opt.delta0 = this.Settings.delta0;

    [~, betahat, sigmahat, X, ~, Y, ~, ~, ~, numEn, ~, p, estimLength, ~, sizeB] = ...
        bear.olsvar(Y_long, X_long, opt.const, opt.lags);
    
    [arvar] = bear.arloop(Y_long, opt.const, p, numEn);

    [yt, y, ~, Xbart, Xbar] = bear.tvbvarmat(Y, X, numEn, sizeB, estimLength); %create TV matrices
    [chi, psi, ~, ~, H, I_tau, G, I_om, f0, upsilon0] = bear.tvbvar2prior(arvar, numEn, sizeB, estimLength, opt.gamma);

    GIG = G' * I_om * G;
    
    % set tau as a large value
    tau = 10000;
    
    % set omega as a large value
    om = 5;
    
    % compute psibar
    chibar = (chi + estimLength) / 2;
        
    % compute alphabar
    alphabar = estimLength + opt.alpha0;

    % initial value for B
    B = kron(ones(estimLength, 1), betahat);

    % initial value Omega
    omega = diag(diag(betahat * betahat'));
    
    % invert Omega
    invomega = diag(1 ./ diag(omega));
    
    % initial value for f_2, ..., f_n
    % obtain the triangular factorisation of sigmahat
    [Fhat,  Lambdahat] = bear.triangf(sigmahat);
    
    % obtain the inverse of Fhat
    [invFhat] = bear.invltod(Fhat, numEn);
    
    % create the cell storing the different vectors of invF
    Finv = cell(numEn, 1);
    
    % store the vectors
    for ii = 2:numEn
        Finv{ii, 1} = invFhat(ii, 1:ii - 1);
    end
    
    % initial values for L_1, ..., L_n
    L = zeros(estimLength, numEn);
    
    % initial values for phi_1, ..., phi_n
    phi = ones(1, numEn);
    
    % initiate invsigmabar
    invsigmabar = sparse(kron(eye(estimLength), inv(sigmahat)));
    
    % step 2: determine the sbar values and Lambda
    sbar = diag(Lambdahat);
    Lambda = sparse(diag(sbar));
    
    % step 3: recover the series of initial values for lambda_1, ..., lambda_T and sigma_1, ..., sigma_T
    lambda_t  =  repmat(diag(sbar), 1, 1, estimLength);
    sigma_t   =  repmat(sigmahat, 1, 1, estimLength);
    epst = zeros(numEn , 1 , estimLength);


    function sampleStruct  =  sampler()
    
        % step 4: draw B
        invomegabar = H' * kron(I_tau, invomega) * H + Xbar' * invsigmabar * Xbar;
        
        % compute the choleski of invomegabar
        C = chol(bear.nspds(invomegabar), 'Lower');
        
        % compute temporary value
        temp = Xbar' * invsigmabar * y;
        
        % smoothing phase: solve by back substitution
        temp1 = C \ temp;
        
        % smoothing phase: solve by forward substitution
        Bbar = C' \ temp1;
        
        % simulation phase:
        B = Bbar + C' \ randn(sizeB * estimLength, 1);
        
        % reshape
        Beta = reshape(B, sizeB, estimLength);
    
        % step 5: draw omega from its posterior
        % compute the summ
        summ = (1 / tau) * Beta(:, 1) * Beta(:, 1)';
        
        for zz = 2:estimLength
            summ = summ + (Beta(:, zz) - Beta(:, zz - 1)) * (Beta(:, zz) - Beta(:, zz - 1))';
        end
        
        summ = diag(summ);
    
        % obtain Qbar
        psibar = summ + psi;
        
        % draw omega
        omega = diag(arrayfun(@bear.igrandn, kron(ones(sizeB, 1), chibar), psibar));
        
        % invert it for next iteration
        invomega = diag(1 ./ diag(omega));
    
        % step 6: draw the series f_2, ..., f_n from their conditional posteriors
        % recover first the residuals
        for jj = 1:estimLength
            epst(:, :, jj) = yt(:, :, jj) - Xbart{jj, 1} * Beta(:, jj);
        end
    
        % then draw the vectors in turn
        for jj = 2:numEn
            % first compute the summations required for upsilonbar and fbar
            summ1 = zeros(jj - 1, jj - 1);
            summ2 = zeros(jj - 1, 1);
            
            % run the summation
            for kk = 1:estimLength
                prodt = epst(1:jj - 1, 1, kk) * exp( - L(kk, jj));
                summ1 = summ1 + prodt * epst(1:jj - 1, 1, kk)';
                summ2 = summ2 + prodt * epst(jj, 1, kk)';
            end
            
            summ1 = (1 / sbar(jj, 1)) * summ1;
            summ2 = ( - 1 / sbar(jj, 1)) * summ2;
    
            % then obtain the inverse of upsilon0
            invupsilon0 = diag(1 ./ diag(upsilon0{jj, 1}));
            
            % obtain upsilonbar
            invupsilonbar = summ1 + invupsilon0;
            C = chol(bear.nspd(invupsilonbar));
            invC = C \ speye(jj - 1);
            upsilonbar = full(invC * invC');
            
            % recover fbar
            fbar = upsilonbar * (summ2 + invupsilon0 * f0{jj, 1});
            
            % finally draw f_i^( - 1)
            Finv{jj, 1} = fbar + chol(bear.nspd(upsilonbar), 'lower') * randn(jj - 1, 1);
        end
        
        % recover the inverse of F
        invF = eye(numEn);
        
        for jj = 2:numEn
            invF(jj, 1:jj - 1) = Finv{jj, 1};
        end
        
        % eventually recover F
        F = bear.invltod(invF, numEn);
        
        % then update sigma
        sigma = F * Lambda * F';
    
        % step 7: draw the series phi_1, ..., phi_n from their conditional posteriors
        % draw the parameters in turn
        for jj = 1:numEn
            % estimate deltabar
            deltabar = L(:, jj)' * GIG * L(:, jj) + opt.delta0;
            
            % draw the value phi_i
            phi(1, jj) = bear.igrandn(alphabar / 2, deltabar / 2);
        end
    
        % step 8: draw the series lambda_i, t from their conditional posteriors,  i = 1, ..., numEn and t = 1, ..., estimLength
        % consider variables in turn
        for jj = 1:numEn
            % consider periods in turn
            for kk = 1:estimLength
                % a candidate value will be drawn from N(lambdabar, phibar)
                % the definitions of lambdabar and phibar varies with the period,  thus define them first
                % if the period is the first period
                
                if kk == 1
                    lambdabar = (opt.gamma * L(2, jj)) / (1 / om + opt.gamma^2);
                    phibar = phi(1, jj) / (1 / om + opt.gamma^2);
                    % if the period is the final period
                elseif kk == estimLength
                    lambdabar = opt.gamma * L(estimLength - 1, jj);
                    phibar = phi(1, jj);
                    % if the period is any period in - between
                else
                    lambdabar = (opt.gamma / (1 + opt.gamma^2)) * (L(kk - 1, jj) + L(kk + 1, jj));
                    phibar = phi(1, jj) / (1 + opt.gamma^2);
                end
    
                % now draw the candidate
                cand = lambdabar + phibar^0.5 * randn;
                
                % compute the acceptance probability
                prob = bear.mhprob2(jj, cand, L(kk, jj), sbar(jj, 1), epst(:, 1, kk), Finv{jj, 1});
                
                % draw a uniform random number
                draw = rand;
                
                % keep the candidate if the draw value is lower than the prob
                if draw <= prob
                    L(kk, jj) = cand;
                    % if not,  just keep the former value
                end
            end
        end
        
        % then recover the series of matrices lambda_t and sigma_t
        for jj = 1:estimLength
            lambda_t(:, :, jj) = diag(sbar) .* diag(exp(L(jj, :)));
            sigma_t(:, :, jj) = F * lambda_t(:, :, jj) * F';
        end
    
        % record the results
        sampleStruct.beta = mat2cell(B,repmat(sizeB,estimLength,1));
        sampleStruct.omega = diag(omega);
        sampleStruct.F = F;
        sampleStruct.L = mat2cell(L, ones(estimLength, 1), numEn);
        sampleStruct.phi = phi;
        sampleStruct.sigma_avg = sigma(:);
    
        for jj = 1:estimLength
            sampleStruct.lambda_t{jj, 1}(:, :) = lambda_t(:, :, jj);
            sampleStruct.sigma_t{jj, 1}(:, :) = sigma_t(:, :, jj);
        end
    end

    outSampler = @sampler;

end

