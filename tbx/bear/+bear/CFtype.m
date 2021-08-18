classdef CFtype < uint8
    %CFTYPE type of conditional forecasts
    
    enumeration
        Standard_all      (1) % standard (all shocks)
        Standard_specific (2) % standard (shock-specific)
        Tilting_median    (3) % tilting (median)
        Tilting_interval  (4) % tilting (interval)
    end

end