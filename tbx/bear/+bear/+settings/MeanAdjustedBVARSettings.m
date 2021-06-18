classdef MeanAdjustedBVARSettings < bear.settings.BASELINESettings

    methods
        
        function obj = MeanAdjustedBVARSettings(excelPath, varargin)
            
            obj@bear.settings.BASELINESettings(3, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end