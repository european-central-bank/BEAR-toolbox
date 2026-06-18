classdef PANELtype < uint8
    %Panel enmieration class to define the differnt type of panel objects
    %that can be run in a PanelVAR
    
    enumeration
        Mge                 (1) % OLS mean group estimator
        Pooled              (2) % pooled estimator      
        Random_zh           (3) % random effect (Zellner and Hong)
        Random_hierarchical (4) % random effect (hierarchical)
        Factor_static       (5) % static factor approach
        Factor_dynamic      (6) % dynamic factor approach
    end
    
end