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
addParameter(p,'BEARData', bear.data.ExcelDAL.empty(), @(x) isa(x, 'bear.data.BEARDAL'));
addParameter(p,'BEARExporter', bear.data.BEARExcelWriter, @(x) isa(x, 'bear.data.Exporter'));
parse(p, VARtype, varargin{:});

if isempty(p.Results.BEARData)
    dal = bear.data.ExcelDAL(p.Results.ExcelFile);
else
    dal = p.Results.BEARData;
end

exporter = p.Results.BEARExporter;

VARtype = bear.VARtype(p.Results.VARtype);

if isempty(fieldnames(p.Unmatched))
    params = {};
else
    params = namedargs2cell(p.Unmatched);
end

switch VARtype
    
    case 1
        settings = bear.settings.OLSsettings(dal, exporter, params{:});
    case 2
        settings = bear.settings.BVARsettings(dal, exporter, params{:});
    case 4
        settings = bear.settings.PANELsettings(dal, exporter, params{:});
    case 5
        settings = bear.settings.SVsettings(dal, exporter, params{:});
    case 6
        settings = bear.settings.TVPsettings(dal, exporter, params{:});
    case 7
        settings = bear.settings.MFVARsettings(dal, exporter, params{:});
        
end

end