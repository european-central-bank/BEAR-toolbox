classdef OLSVARsettings < bear.settings.BASELINEsettings
    
    properties
        strctident
    end
    
    properties (SetAccess = private)
        panel (1,1) double = 10; % panel scalar (non-model value): required to have the argument for interface 6, even if a non-panel model is selected
    end
    
    methods
        
        function obj = OLSVARsettings(excelPath, varargin)
            
            obj@bear.settings.BASELINEsettings(1, excelPath)

            obj = obj.setStrctident(obj.IRFt);
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end

    methods (Access = protected)

        function obj = checkIRFt(obj, value)
            % we could call superclass method to combine effect
            obj = checkIRFt@bear.settings.BASELINEsettings(obj, value);
            obj = obj.setStrctident(value);
        end
        
    end

    methods (Access = private)

        function obj = setStrctident(obj, value)
            
            switch value
                case 4
                    obj.strctident = bear.settings.StrctidentIRFt4;
                case 5                    
                    obj.strctident = bear.settings.StrctidentIRFt5;
                case 6
                    obj.strctident = bear.settings.StrctidentIRFt6;
            end
            
        end

    end
end