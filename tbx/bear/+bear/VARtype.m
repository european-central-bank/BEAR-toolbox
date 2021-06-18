classdef VARtype < uint8
    %VARTYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        OLSVAR      (1) % OLS VAR
        MeanAdjBVAR (2) % Mean Adjusted BVAR
        BVAR        (3) % Bayesian VAR 
        PanelBVAR   (4) % Panel BVAR
        SVBVAR      (5) % Stochastic Volatility BVAR
        TVPBVAR     (6) % Time-Varying Parameter BVAR
    end
    
end