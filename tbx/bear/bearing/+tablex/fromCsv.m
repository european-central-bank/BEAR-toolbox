%{{{ +tablex/fromCSV
%
% `fromCSV`
% ==========
%
% Read a CSV file and convert it to a time table
%
%     tt = tablex.fromCsv(filename, ___)
%
%
% Input arguments
% ----------------
%
% * `filename`:  Name of the CSV file to read
%
%
% Options
% --------
%
% * `timeColumn="Time"`: Name of the column in the CSV file that will be used as
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
% * `tt`: Time table created from the CSV file.
%
%}}}

function varargout = fromCsv(varargin)

    [varargout{1:nargout}] = tablex.fromFile( ...
        varargin{:} ...
        , "fileType", "text" ...
    );

end%

