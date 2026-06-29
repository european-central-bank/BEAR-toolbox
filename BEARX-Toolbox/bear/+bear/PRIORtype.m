
classdef PRIORtype < uint8
    %PRIOR type 
    
    enumeration
        
        Minnesota_univariate (11) % 11=Minnesota (univariate AR)
        Minnesota_diagonal   (12) % 12=Minnesota (diagonal VAR estimates)
        Minnesota_full       (13) % 13=Minnesota (full VAR estimates)
        Nw_univariate        (21) % 21=Normal-Wishart(S0 as univariate AR)
        Nw_identity          (22) % 22=Normal-Wishart(S0 as identity)
        Inw_univariate       (31) % 31=Independent Normal-Wishart(S0 as univariate AR)
        Inw_identity         (32) % 32=Independent Normal-Wishart(S0 as identity)
        Nd                   (41) % 41=Normal-diffuse 
        Dummy                (51) % 51=Dummy observations
        Madj                 (61) % 61=Mean-adjusted
    
    end

end