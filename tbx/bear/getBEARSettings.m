function [settings] = getBEARSettings(VARType, ExcelPath, varargin)
%GETBEARSETTINGS Summary of this function goes here
%   Detailed explanation goes here
VARType = bear.VARtype(VARType);

switch VARType
    
    case 1
        settings = bear.settings.OLSVARSettings(ExcelPath, varargin{:});
    case 2
        settings = bear.settings.MeanAdjustedBVARSettings(ExcelPath, varargin{:});
    case 3
        settings = bear.settings.BVARSettings(ExcelPath, varargin{:});
    case 4
        settings = bear.settings.PanelBayesianVARSettings(ExcelPath, varargin{:});
    case 5
        settings = bear.settings.StochasticVolatilityBVARSettings(ExcelPath, varargin{:});
    case 6
        settings = bear.settings.TimeVaryingSettings(ExcelPath, varargin{:});
        
end

end

