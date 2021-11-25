function [settings] = BEARsettings(VARtype, varargin)
%BEARSETTINGS gets the corresponding settings object based on the given
%VARtype. The user can optionally pass a name-value property with the
%ExcelFile. Alternatively, the xlsx file in pwd is taken. If more than one
%xlsx file exist an error is thrown. It is also possible to pass any of the
%VARtype properties as name-value pairs.

p = inputParser;
p.KeepUnmatched = true;
addRequired(p, 'VARtype', @(x) isnumeric(x) || isstring(x) || ischar(x));
addParameter(p,'ExcelFile', fullfile(bearroot(), 'default_bear_data.xlsx'), @(x) isstring(x) || ischar(x));
parse(p, VARtype, varargin{:});

VARtype = bear.VARtype(p.Results.VARtype);

ExcelFile = p.Results.ExcelFile;

if isempty(fieldnames(p.Unmatched))
    params = {};
else
    params = namedargs2cell(p.Unmatched);
end

switch VARtype
    
    case 1
        settings = bear.settings.OLSsettings(ExcelFile, params{:});
    case 2
        settings = bear.settings.BVARsettings(ExcelFile, params{:});
    case 4
        settings = bear.settings.PANELsettings(ExcelFile, params{:});
    case 5
        settings = bear.settings.SVsettings(ExcelFile, params{:});
    case 6
        settings = bear.settings.TVPsettings(ExcelFile, params{:});
    case 7
        settings = bear.settings.MFVARsettings(ExcelFile, params{:});
        
end

end