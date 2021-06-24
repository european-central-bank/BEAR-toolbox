classdef Panel < uint8
    %Panel enmieration class to define the differnt type of panel objects
    %that can be run in a PanelVAR
    
    enumeration
        OLS_mean_group_estimator         (1) % OLS mean group estimator
        pooled_estimator                 (2) % pooled estimator      
        random_effect_Zellner_and_Hong   (3) % random effect (Zellner and Hong)
        random_effect_hierarchical       (4) % random effect (hierarchical)
        static_factor_approach           (5) % static factor approach
        dynamic_factor_approach          (6) % dynamic factor approach
    end
    
end