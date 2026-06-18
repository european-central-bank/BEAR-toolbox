function [prep] = favar_nwprep(n, m, p, k, T, q, data_endo, ar, arvar, ...
                    lambda1, lambda3, lambda4, prior, priorexo, favar, X)
        
    if favar.onestep == 1
        prep.indexnM = favar.indexnM;
    else
        prep.indexnM = [];
    end
    
    if favar.onestep == 0 %static factors in this case
        prep.FY = data_endo;
    else
        prep.FY = [];
    end

    temp = bear.lagx(data_endo, p);
    Y = temp(:,1:n);
 
    % state-space representation
    if favar.onestep == 1

        Bhat = (X'*X)\(X'*Y);
        EPS  = Y - X*Bhat;
        prep.B_ss = [Bhat'; eye(n*(p - 1)) zeros(n*(p - 1), n)];
        prep.sigma_ss = [(1/T)*(EPS'*EPS) zeros(n, n*(p - 1)); zeros(n*(p - 1), n*p)];
       
        prep.Bbar = [];
        prep.phibar = [];
        prep.Sbar = [];
        prep.alphabar = [];  
        prep.alphatilde = [];
    
    elseif favar.onestep == 0
    
        % set prior values
        [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, lambda1, lambda3, lambda4, n, m, p, k, q, prior, priorexo);
        
        % obtain posterior distribution parameters
        [prep.Bbar, ~, prep.phibar, prep.Sbar, prep.alphabar, prep.alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, X, Y, n, T, k);
    
        prep.B_ss = [];
        prep.sigma_ss = [];

    end

end

    
