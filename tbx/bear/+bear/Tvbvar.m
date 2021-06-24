classdef Tvbvar < uint8
    %TVBVAR enmueration class to define the differnt type of Time Varying
    %VAR problems
    
    enumeration
        time_varying_coefficients (1) % time-varying coefficients
        general_time_varying      (2) % general_time_varying
    end

end