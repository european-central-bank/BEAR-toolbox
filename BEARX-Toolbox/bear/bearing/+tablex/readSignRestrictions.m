
function tbl = readSignRestrictions(filename, varargin)

    arguments
        filename (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    tbl = tablex.readtable( ...
        filename ...
        , "convertTo", @string  ...
        , varargin{:} ...
    );

end%

