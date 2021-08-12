function [settings] = BEARsettings(VARType, varargin)
%BEARSETTINGS gets the corresponding settings object based on the given
%VARtype. The user can optionally pass a name-value property with the
%ExcelPath. Alternatively, the xlsx file in pwd is taken. If more than one
%xlsx file exist an error is thrown. It is also possible to pass any of the
%VARtype properties as name-value pairs.

p = inputParser;
p.KeepUnmatched = true;
addRequired(p, 'VARType', @(x) isnumeric(x) || isstring(x) || ischar(x));
addParameter(p,'ExcelPath', '', @(x) isstring(x) || ischar(x));
parse(p, VARType, varargin{:});

VARType = bear.VARtype(p.Results.VARType);

ExcelPath = p.Results.ExcelPath;
if isempty(ExcelPath)
    ExcelPath = getExcelpath();
end

if isempty(fieldnames(p.Unmatched))
    params = {};
else
    params = namedargs2cell(p.Unmatched);
end

switch VARType
    
    case 1
        settings = bear.settings.OLSsettings(ExcelPath, params{:});
    case 2        
        settings = bear.settings.BVARsettings(ExcelPath, params{:});
    case 3        
        settings = bear.settings.MADJsettings(ExcelPath, params{:});
    case 4
        settings = bear.settings.PANELsettings(ExcelPath, params{:});
    case 5
        settings = bear.settings.SVsettings(ExcelPath, params{:});
    case 6
        settings = bear.settings.TVPsettings(ExcelPath, params{:});
        
end

end

function var = getExcelpath()
    f = dir('*.xlsx');
    
    if length(f) ~= 1        
        error('bear:settings:UndefinedExcelFile', ...
            'Unable to automatically determine the Excel file, please specifiy the property ExcelPath with the address of the input file');
    end
    
    var = fullfile(f.folder, f.name);
end