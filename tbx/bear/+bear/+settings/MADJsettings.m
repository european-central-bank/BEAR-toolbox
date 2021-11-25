classdef MADJsettings < bear.settings.BASEsettings
% This is the settings template for VARtype 3 which is unused at the
% moment.
    methods
        
        function obj = MADJsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(3, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end