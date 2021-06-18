classdef CFtype < uint8
    %CFTYPE type of conditional forecasts
    
    enumeration
        standard_all_shocks     (1) % standard (all shocks)
        standard_shock_specific (2) % standard (shock-specific)
        tilting_median          (3) % tilting (median)
        tilting_interval        (4) % tilting (interval)
    end

end