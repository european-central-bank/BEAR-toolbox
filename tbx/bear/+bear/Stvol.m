classdef Stvol < uint8
    %VARTYPE enmieration class to define the differnt type of VAR problems
    %that can be solved in BEAR toolbox
    
    enumeration
        standard                (1) % standard, 
        random_scaling          (2) % random scaling
        large_BVAR_TVESLM_Model (3) % large BVAR TVESLM Model 
    end

end