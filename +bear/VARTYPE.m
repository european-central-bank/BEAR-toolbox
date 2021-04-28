classdef VARTYPE < double
    
    enumeration
        OLS    (1) % OLS VAR
        BVAR   (2) % BVAR
        MABVAR (3) % mean-adjusted BVAR
        PBVAR  (4) % panel Bayesian VAR
        SVBVAR (5) % Stochastic volatility BVAR
        TVBVAR (6) % Time varying BVAR
    end
    
end