classdef SVtype < uint8
    %VARTYPE enmieration class to define the differnt type of VAR problems
    %that can be solved in BEAR toolbox
    
    enumeration
        Standard       (1) % standard, 
        Random_scaling (2) % random scaling
        Large_BVAR     (3) % large BVAR TVESLM Model 
        LMM            (4) % Local mean model
    end

end