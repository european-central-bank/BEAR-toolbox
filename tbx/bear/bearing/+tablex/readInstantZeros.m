
function tbl = readInstantZeros(fileName, varargin)

    arguments
        fileName (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    tbl = tablex.readtable( ...
        fileName ...
        , "convertTo", @string  ...
        , varargin{:} ...
    );

    % Validate data in the table
    tablex.validateInstantZeros(tbl);

end%
