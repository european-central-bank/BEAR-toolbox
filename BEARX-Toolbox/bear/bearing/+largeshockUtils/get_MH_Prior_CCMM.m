function [prior] = get_MH_Prior_CCMM(opt, numEn, numBrows, numEx, varScale, modelfreq)

    % Determine whether the prior is conjugate, i.e.~no cross-variable scaling
    isConjugate = opt.lambda2 == 0;
    
    % Prior for Sigma
    prior.scaleSigma  = diag(varScale);
    prior.dofSigma    = numEn + 2;
    
    % Create prior mean of B
    beta0 = zeros(numEn, numEn);
    
    numBenRows = numBrows - numEx;
    
    for idx = 1:numEn
        if isscalar(opt.ar)
            beta0(idx, idx) = opt.ar;
        else
            beta0(idx, idx) = opt.ar(idx, 1);
        end
    end
    
    meanBen = [beta0, zeros(numEn, numBenRows-numEn)]';
    meanBex = zeros(numEn, numEx)';
    prior.meanB = [meanBen; meanBex];
    
    if isConjugate
    
        % Calculate the prior precision for Beq, which is same for all equations when opt.lambda2 = 0
    
        shrinkBenEq = nan(numBenRows, 1);
        for l = 1 : opt.p
            shrinkBenEq((l-1)*numEn+1 : l*numEn) = (opt.lambda1 / (l^opt.lambda3))^2 ./ varScale;
        end
        shrinkBexEq = 1 ./ opt.lambda4 * ones(1, numEx);
    
        precBen = diag(1 ./ shrinkBenEq);
        precBex = diag(1 ./ shrinkBexEq);
    
    else
    
        % Calculate the prior precision for B
    
        covBen = nan(numBenRows, numEn);
        covBex = nan(numEx, numEn);
        for i = 1 : numEn
            c = 0;
            for l = 1 : opt.p
                for j = 1 : numEn
                    c = c + 1;
                    if i == j
                        covBen(c, i) = (opt.lambda1 / l^opt.lambda3)^2;
                    else
                        covBen(c, i) = (opt.lambda1 * opt.lambda2 / l^opt.lambda3)^2 * varScale(i) / varScale(j);
                    end
                end
            end
            covBex(:, i) = 1 ./ opt.lambda4(i);
        end
    
        precBen = 1 ./ covBen;
        precBex = 1 ./ covBex;
    
    end
    
    precB = [precBen; precBex];
    prior.precB   = diag(precB(:));

    prior.covB = inv(prior.precB);
    prior.cholCovB = chol(prior.covB, "lower");


    precF = 1e-6;
    meanFRow = cell(numEn-1, 1);
    precFRow = cell(numEn-1, 1);
    
    for i = 1 : numEn-1
        meanFRow{i} = zeros(1, i);
        precFRow{i} = precF * eye(i);
    end
    
    prior.meanF  = [meanFRow{:}];
    prior.precF  = blkdiag(precFRow{:});
    
    prior.covF       = inv(prior.precF);
    prior.cholCovF   = chol(prior.covF, "lower");
    
    prior.meanlogLambda = zeros(1, numEn);
    prior.preclogLambda = 0.1 * ones(1, numEn);
    prior.covlogLambda = diag(1./prior.preclogLambda);
    prior.cholCovlogLambda = sqrt(prior.covlogLambda);
    
    if isfield(opt, "freqO")
    
        nPriorO     = opt.PriorYears*modelfreq;
        freqPriorO  = 1 / (opt.freqO*modelfreq);
        
        prior.alphaProbO  = freqPriorO * nPriorO * ones(1, numEn);
        prior.betaProbO   = (nPriorO - prior.alphaProbO(1)) * ones(1, numEn);

    end
    
    %Q
    if isfield(opt, "lbDofQ")
        prior.lbDofQ  = opt.lbDofQ * ones(1, numEn);
        prior.ubDofQ  = opt.ubDofQ * ones(1, numEn);
    end
    
    %Phi
    prior.dofPhi    = numEn + 3;
    prior.scalePhi  = opt.scalePhi * prior.dofPhi * eye(numEn);

end

