classdef VARtype < uint8
    %VARTYPE enmieration class to define the differnt type of VAR problems
    %that can be solved in BEAR toolbox
    
    enumeration
        OLSVAR      (1) % OLS VAR
        BVAR        (2) % Bayesian VAR         
        MeanAdjBVAR (3) % Mean Adjusted BVAR
        PanelBVAR   (4) % Panel BVAR
        SVBVAR      (5) % Stochastic Volatility BVAR
        TVPBVAR     (6) % Time-Varying Parameter BVAR
    end

end