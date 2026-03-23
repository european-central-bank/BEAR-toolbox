
function writetable(tbl, fileName, varargin)

    arguments
        tbl (:, :) table
        fileName (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    writetable( ...
        tbl, fileName ...
        , "writeRowNames", true ...
        , "writeVariableNames", true ...
        , varargin{:} ...
    );

end%

