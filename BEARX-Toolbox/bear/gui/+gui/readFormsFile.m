
function content = readFormsFile(path)

    arguments
        path (1, :) cell {mustBeNonempty}
    end

    FORMS_FOLDER = fullfile(".", "forms");

    path = fullfile(FORMS_FOLDER, path{:}) + ".json";
    content = json.read(path);

end%

