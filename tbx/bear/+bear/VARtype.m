classdef VARtype < uint8
    %VARTYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        OLS                      (1)   
        MeanAdjusted             (2)
        BVAR                     (3)  
        PanelBayesian            (4)
        StochasticVolatility     (5)
        TimeVarying              (6)
    end
    
end