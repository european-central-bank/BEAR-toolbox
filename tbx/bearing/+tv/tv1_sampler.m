
function outSampler = adapterSampler(this, YXZ)

    arguments
        this
        YXZ (1, 3) cell
    end

    [Y_long, X_long, ~] = YXZ{:};

    opt.const = this.Settings.HasConstant;
    opt.lags = this.Settings.Order;   
    
    [~, betahat, sigmahat, X, ~, Y, ~, ~, ~, numEn, ~, p, estimLength, ~, sizeB] = ...
        bear.olsvar(Y_long, X_long, opt.const, opt.lags);
    
    [arvar] = bear.arloop(Y_long, opt.const, p, numEn);

    [~, y, ~, ~, Xbar] = bear.tvbvarmat(Y, X, numEn, sizeB, estimLength); %create TV matrices
    [chi, psi, kappa, S, H, I_tau] = bear.tvbvar1prior(arvar, numEn, sizeB, estimLength);

    % preliminary elements for the algorithm
    % set tau as a large value
    
    tau = 10000;
    
    % compute psibar
    chibar = (chi + estimLength) / 2;
    
    % compute alphabar
    kappabar = estimLength + kappa;
    
    % step 1: determine initial values for the algorithm
    
    % initial value for B
    B = kron(ones(estimLength, 1), betahat);
    
    % initial value Omega
    omega = diag(diag(betahat * betahat'));
    
    % invert Omega
    invomega = diag(1 ./ diag(omega));
    
    % initial value for sigma
    sigma = sigmahat;
    
    % invert sigma
    C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
    invC = C \ speye(numEn);
    invsigma = invC * invC';
        
    %% Let's redo X'X and X'Y
    pre_xx = Xbar'*kron(speye(estimLength), ones(numEn, numEn)) * Xbar;   % like setting invsigma to a matrix of (numEn,numEn) ones
    
    pre_xy = NaN(estimLength * sizeB, numEn);
    for i = 1:estimLength
        pre_xy(1 + (i - 1) * sizeB:i * sizeB, :) = kron(ones(numEn, 1), kron(y(1 + (i - 1) * numEn:i * numEn)', ...
            Xbar(1 + numEn * (i - 1), 1 + sizeB * (i - 1):sizeB * (i - 1) + sizeB / numEn)'));
    end


    function sampleStruct  =  sampler()
    
        % step 2: draw B
        invomegabar = H' * kron(I_tau, invomega) * H + ...
            kron(speye(estimLength), kron(invsigma, ones(sizeB / numEn, qq / numEn))) .* pre_xx;
        
        % compute temporary value
        temp = sum(kron(ones(estimLength, 1), kron(invsigma, ones(sizeB / numEn, 1))) .* pre_xy, 2);
        
        % solve
        Bbar = invomegabar \ temp;
        
        % simulation phase:
        B = Bbar + chol(invomegabar, 'Lower')' \ randn(sizeB * estimLength, 1);
        % reshape
        Beta=reshape(B, sizeB, estimLength);
        
        % step 3: draw omega from its posterior
        % compute psibar
        psibar = (1 / tau) * Beta(:, 1).^2 + sum((Beta(:, 2:estimLength) - Beta(:, 1:estimLength - 1)).^2, 2) + psi;
        
        % draw omega
        omega = diag(arrayfun(@bear.igrandn, kron(ones(sizeB, 1), chibar), psibar / 2));
        
        % invert it for next iteration
        invomega = diag(1 ./ diag(omega));
        
        % step 4: draw sigma from its posterior
        %estimate the residuals
        eps = y - Xbar * B;
        Eps = reshape(eps, numEn, estimLength);

        % estimate Sbar
        Sbar = Eps * Eps' + S;

        % draw sigma
        sigma = bear.iwdraw(Sbar, kappabar);
        
        % invert it for next iteration
        C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
        invC = C \ speye(numEn);
        invsigma = invC * invC';
        
        % record phase
        sampleStruct.beta = mat2cell(B, repmat(sizeB, estimLength, 1));
        sampleStruct.omega = diag(omega);
        sampleStruct.sigma = sigma(:);        
    end

    outSampler = @sampler;

end

