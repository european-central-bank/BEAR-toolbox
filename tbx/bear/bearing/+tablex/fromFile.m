
function [tt, freq, tbl] = fromFile(fileName, options)

    arguments
        fileName (1, 1) string
        %
        options.FileType (1, 1) string = ""
        options.TimeColumn (1, 1) string = "Time"
        options.Frequency (1, 1) double = NaN
        options.DateFormat (1, 1) string = "sdmx"
        options.Trim (1, 1) logical = true
        options.Sheet = 1
        options.VariableNamingRule (1, 1) string = "preserve"
        %
        options.ConvertTo = []
        options.ReplaceMissing (1, 1) logical = true
    end

    [tbl, timeColumn] = readPlainTable__(fileName, options);

    periodConstructorDispatcher = struct( ...
        lower("sdmx"), @datex.fromSdmx ...
        , lower("legacy"), @datex.fromLegacy ...
    );

    periodConstructor = periodConstructorDispatcher.(lower(options.DateFormat));

    if ~isempty(options.ConvertTo)
        tbl = tablex.convert(tbl, options.ConvertTo, timeColumn=timeColumn);
    end

    if options.ReplaceMissing
        tbl = tablex.replaceMissing(tbl, timeColumn=timeColumn);
    end

    %
    % Convert the plain table to a timetable
    %
    [tt, freq] = tablex.fromTable( ...
        tbl ...
        , timeColumn=timeColumn ...
        , frequency=options.Frequency ...
        , periodConstructor=periodConstructor ...
        , trim=options.Trim ...
    );

end%


function [tbl, timeColumn] = readPlainTable__(fileName, options)
    %[
    options.FileType = tryAutoDetectFileType__(options.FileType, fileName);

    args = {
        "textType", "string" ...
        "variableNamingRule", options.VariableNamingRule, ...
    };
    if options.FileType ~= ""
        args = [args, {"fileType", options.FileType}];
    end
    if ~isempty(options.Sheet) && ~isequal(options.Sheet, 1)
        args = [args, {"sheet", options.Sheet}];
    end

    %
    % If a time column name is specified, try first to load the file as a
    % table without row names, and check if the columns include a time
    % column.
    %
    % If not, throw a warning, and try to read the file as a table with row
    % names instead.
    %
    % If no time column name is specified, read the file as a table with
    % row names, create an auto name for the time column ("Time"), and add
    % the row names as a new first data column, and remove row names.
    %

    timeColumn = options.TimeColumn;

    if ~isequal(timeColumn, "")
        tbl = readtable(fileName, args{:});
        names = tablex.names(tbl);
        if ismember(timeColumn, names)
            return
        end
        warning(join([ ...
            "The spreadsheet does not contain the time column '%s'.", ...
            "Will read the file again assuming the time column has no name.", ...
        ], newline()), timeColumn);
    end
    
    tbl = readtable(fileName, "readRowNames", true, args{:});
    timeData = reshape(string(tbl.Properties.RowNames), [], 1);
    if isequal(timeColumn, "")
        timeColumn = "Time";
    end
    tbl = addvars( ...
        tbl, timeData ...
        , newVariableNames=timeColumn ...
        , before=1 ...
    );
    tbl.Properties.RowNames = string.empty(0);
    %]
end%


function fileType = tryAutoDetectFileType__(fileType, fileName)
    %[
    FILETYPES = struct( ...
        xlsx="spreadsheet" ...
        , xls="spreadsheet" ...
        , csv="text" ...
        , txt="text" ...
    );
    %
    if fileType == ""
        [~, ~, fileExt] = fileparts(fileName);
        fileExt = extractAfter(string(fileExt), ".");
        try
            fileType = FILETYPES.(lower(fileExt(2:end)));
        catch
            % Do nothing
        end
    end
    %]
end%
