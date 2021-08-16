classdef OLSsettings < bear.settings.BASEsettings
    %OLSSETTINGS Panel VAR settings class
    %   The bear.settings.OLSsettings class is a class that creates a settings
    %   object to run a OLS VAR. It can be created directly by running:
    %
    %   bear.settings.OLSsettings(ExcelPath, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('OLS', ExcelPath = 'path/To/file.xlsx')
    %
    % OLSsettings Properties:
    %    strctident - Choice of panel model

    properties
        % strctident
        strctident
    end
    
    methods
        
        function obj = OLSsettings(excelPath, varargin)
            
            obj@bear.settings.BASEsettings(1, excelPath)

            obj = obj.setStrctident(obj.IRFt);
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end

    methods (Access = protected)

        function obj = checkIRFt(obj, value)
            % we could call superclass method to combine effect
            obj = checkIRFt@bear.settings.BASEsettings(obj, value);
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
                otherwise
                    obj.strctident = bear.settings.Strctident.empty();
            end
            
        end

    end
end