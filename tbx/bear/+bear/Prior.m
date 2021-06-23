classdef Prior < uint8
    %PRIOR type 
    
    enumeration
        
        Minnesota_Univariate_AR          (11) % 11=Minnesota (univariate AR)
        Minnesota_diagonal_VAR_estimates (12) % 12=Minnesota (diagonal VAR estimates)
        Minnesota_full_VAR_estimate      (13) % 13=Minnesota (full VAR estimates)
        Normal_Wishart_S0_AR             (21) % 21=Normal-Wishart(S0 as univariate AR)
        Normal_Wishart_S0_ID             (22) % 22=Normal-Wishart(S0 as identity)
        Independent_Normal_Wishart_S0_AR (31) % 31=Independent Normal-Wishart(S0 as univariate AR)
        Independent_Normal_Wishart_S0_ID (32) % 32=Independent Normal-Wishart(S0 as identity)
        Normal_diffuse                   (41) % 41=Normal-diffuse 
        Dummy_observations               (51) % 51=Dummy observations
        Mean_adjusted                    (61) % 61=Mean-adjusted
    
    end

end