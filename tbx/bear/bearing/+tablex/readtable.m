
function tbl = readtable(fileName, varargin, options)

    arguments
        fileName (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    arguments
        options.ConvertTo = []
        options.ReplaceMissing (1, 1) logical = true
    end

    tbl = readtable( ...
        fileName ...
        , "textType", "string" ...
        , "readRowNames", true ...
        , "readVariableNames", true ...
        , "variableNamingRule", "preserve" ...
        , varargin{:} ...
    );

    if ~isempty(options.ConvertTo)
        tbl = tablex.convert(tbl, options.ConvertTo);
    end

    if options.ReplaceMissing
        tbl = tablex.replaceMissing(tbl);
    end

end%

