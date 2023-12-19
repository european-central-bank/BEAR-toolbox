function [settings] = BEARsettings(VARtype, varargin)
% BEARSETTINGS gets the corresponding settings object based on the given
% VARtype. 
% opts = BEARsettings(VARtype, name = value)
% opts = BEARsettings(VARtype, ExcelFile = 'data.xlsx', name = value)
%
% VARtype is the type of BEAR to be estimated, and can take the values
% OLS, BVAR, PANEL, SV, TVP, MFVAR. 
%
% ExcelFile is an optional key-value pair with the location in disk of the
% Excel file with the inputs. If not specified, BEAR will use a default
% one. 
%
% It is also possible to pass any of the % VARtype properties as name-value
% paris. These will depend on the choosen VARtype
%
% See also:
% <a href="matlab:doc('bear.settings.BASEsettings')">Base settings for BEAR</a>
% <a href="matlab:doc('bear.settings.BVARsettings')">BVAR settings</a>
% <a href="matlab:doc('bear.settings.OLSsettings')">OLS settings</a>
% <a href="matlab:doc('bear.settings.PANELsettings')">Panel settings</a>
% <a href="matlab:doc('bear.settings.SVsettings')">Stocahstic Volatility</a>
% <a href="matlab:doc('bear.settings.TVPsettings')">Time Varing panel settings</a>
% <a href="matlab:doc('bear.settings.MFVARsettings')">Mixed Frequency</a>

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