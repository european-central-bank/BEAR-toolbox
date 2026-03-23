
function writetimetable(tbl, fileName, varargin)

    arguments
        tbl (:, :) timetable
        fileName (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    writetimetable( ...
        tbl, fileName ...
        , "writeVariableNames", true ...
        , varargin{:} ...
    );

end%

