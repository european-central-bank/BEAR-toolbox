classdef MADJsettings < bear.settings.BASEsettings

    methods
        
        function obj = MADJsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(3, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end