classdef TVPtype < uint8
    %TVBVAR enmueration class to define the differnt type of Time Varying
    %VAR problems
    
    enumeration
        TVP         (1) % time-varying coefficients, time-invariant volatility
        TVP_SV      (2) % time-varying coefficients and volatility (general_time_varying)
    end

end