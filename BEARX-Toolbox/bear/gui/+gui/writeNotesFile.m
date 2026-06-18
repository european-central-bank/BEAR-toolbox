
function writeNotesFile(content, path, varargin)

    arguments
        content
        path (1, :) cell
    end

    arguments (Repeating)
        varargin
    end

    FORMS_FOLDER = fullfile(".", "forms");

    path = fullfile(FORMS_FOLDER, path{:}) + ".txt";

    writematrix( ...
        content, path ...
        , "quoteStrings", false ...
        , varargin{:} ...
    );

end%

