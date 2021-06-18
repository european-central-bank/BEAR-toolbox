classdef MeanAdjBVARsettings < bear.settings.BASELINEsettings

    methods
        
        function obj = MeanAdjBVARsettings(excelPath, varargin)
            
            obj@bear.settings.BASELINEsettings(3, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end