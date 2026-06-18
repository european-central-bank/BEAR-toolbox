%{{{ +tablex/fromCSV
%
% `fromXls`
% ==========
%
% Read an Excel spreadsheet file and convert it to a timetable
%
%     tt = tablex.fromXls(filename, ___)
%
%
% Input arguments
% ----------------
%
% * `filename`:  Name of the XLS file to read
%
%
% Options
% --------
%
% * `timeColumn="Time"`: Name of the column in the XLS file that will be used as
% the time column.
%
% * `frequency=NaN`: Time frequency as an integer; one of 1, 2, 4, 6, 12, 52, 365.
%
% * `dateFormat="sdmx"`: Date format in the time column; one of "sdmx" or
% "legacy".
%
%
% Output arguments
% -----------------
%
% * `tt`: Time table created from the XLS file.
%
%}}}

function varargout = fromXls(varargin)

    [varargout{1:nargout}] = tablex.fromFile( ...
        varargin{:} ...
        , "fileType", "spreadsheet" ...
    );

end%

