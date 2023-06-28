classdef VARtype < uint8
    %VARTYPE enmieration class to define the differnt type of VAR problems
    %that can be solved in BEAR toolbox
    
    enumeration
        OLS   (1) % OLS VAR
        BVAR  (2) % Bayesian VAR         
        PANEL (4) % Panel BVAR
        SV    (5) % Stochastic Volatility BVAR
        TVP   (6) % Time-Varying Parameter BVAR
        MFVAR (7) % Time-Varying Parameter BVAR
    end

end