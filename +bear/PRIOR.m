classdef PRIOR < double
    
    enumeration
        MinnesotaUAR       (11) % 11=Minnesota (univariate AR),
        MinnesotaDVARE     (12) % 12=Minnesota (diagonal VAR estimates),
        MinnesotaFVar      (13) % 13=Minnesota (full VAR estimates)
        NormalWishartSOUAR (21) % 21=Normal-Wishart(S0 as univariate AR),
        NormalWishartSOI   (22) % 22=Normal-Wishart(S0 as identity)
        IndependentNWSOUAR (31) % 31=Independent Normal-Wishart(S0 as univariate AR),
        IndependentNWSOI   (32) % 32=Independent Normal-Wishart(S0 as identity)
        NormalDiffuse      (41) % 41=Normal-diffuse
        DummyObservations  (51) % 51=Dummy observations
        MeanAdjusted       (61) % 61=Mean-adjusted
    end
    
end