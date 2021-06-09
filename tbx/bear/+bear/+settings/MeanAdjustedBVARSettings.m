classdef MeanAdjustedBVARSettings < bear.settings.BaseSettings

    methods
        
        function obj = MeanAdjustedBVARSettings(excelPath, varargin)
            
            obj@bear.settings.BaseSettings(3, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end