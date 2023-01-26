classdef OLSsettings < bear.settings.BASEsettings
    %OLSSETTINGS Panel VAR settings class
    %   The bear.settings.OLSsettings class is a class that creates a settings
    %   object to run a OLS VAR. It can be created directly by running:
    %
    %   bear.settings.OLSsettings(ExcelFile, varargin)
    %
    %   or in its more convenient form:
    %
    %   BEARsettings('OLS', ExcelFile = 'path/To/file.xlsx')
    %
    % OLSsettings Properties:
    %    strctident - Choice of panel model
    %    favar - FAVAR Options

    properties
        % strctident
        strctident

        % FAVAR options
        favar (1,1) bear.settings.favar.FAVARsettings = bear.settings.favar.FAVARsettings(); % augment VAR model with factors (1=yes, 0=no)
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
                    if ~isa(obj.strctident, "bear.settings.strctident.StrctidentIRFt4")
                        obj.strctident = bear.settings.strctident.StrctidentIRFt4;
                    end
                case 5
                    if ~isa(obj.strctident, "bear.settings.strctident.StrctidentIRFt5")
                        obj.strctident = bear.settings.strctident.StrctidentIRFt5;
                    end
                case 6
                    if ~isa(obj.strctident, "bear.settings.strctident.StrctidentIRFt6")
                        obj.strctident = bear.settings.strctident.StrctidentIRFt6;
                    end
                otherwise
                    obj.strctident = bear.settings.strctident.Strctident.empty();
            end

        end

    end
end
