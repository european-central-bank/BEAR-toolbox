function [settings] = BEARsettings(VARType, ExcelPath, varargin)
%GETBEARSETTINGS gets the corresponding settings object based on the given
%VARtype.

VARType = bear.VARtype(VARType);

switch VARType
    
    case 1
        settings = bear.settings.OLSsettings(ExcelPath, varargin{:});
    case 2        
        settings = bear.settings.BVARsettings(ExcelPath, varargin{:});
    case 3        
        settings = bear.settings.MADJsettings(ExcelPath, varargin{:});
    case 4
        settings = bear.settings.PANELsettings(ExcelPath, varargin{:});
    case 5
        settings = bear.settings.SVsettings(ExcelPath, varargin{:});
    case 6
        settings = bear.settings.TVPsettings(ExcelPath, varargin{:});
        
end

end