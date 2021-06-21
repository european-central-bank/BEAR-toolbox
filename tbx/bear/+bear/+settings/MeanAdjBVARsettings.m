classdef MeanAdjBVARsettings < bear.settings.BASELINEsettings
    
    properties (SetAccess = private)
        panel (1,1) double = 10; % panel scalar (non-model value): required to have the argument for interface 6, even if a non-panel model is selected
    end

    methods
        
        function obj = MeanAdjBVARsettings(excelPath, varargin)
            
            obj@bear.settings.BASELINEsettings(3, excelPath)
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
    
end