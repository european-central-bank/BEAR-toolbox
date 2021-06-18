function [settings] = BEARSettings(VARType, ExcelPath, varargin)
%GETBEARSETTINGS Summary of this function goes here
%   Detailed explanation goes here
VARType = bear.VARtype(VARType);

switch VARType
    
    case 1
        settings = bear.settings.OLSVARsettings(ExcelPath, varargin{:});
    case 2
        settings = bear.settings.MeanAdjBVARsettings(ExcelPath, varargin{:});
    case 3
        settings = bear.settings.BVARSettings(ExcelPath, varargin{:});
    case 4
        settings = bear.settings.PanelBVARsettings(ExcelPath, varargin{:});
    case 5
        settings = bear.settings.SVBVARsettings(ExcelPath, varargin{:});
    case 6
        settings = bear.settings.TVPBVARsettings(ExcelPath, varargin{:});
        
end

end

