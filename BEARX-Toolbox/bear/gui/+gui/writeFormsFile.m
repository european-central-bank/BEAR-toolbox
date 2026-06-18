
function writeFormsFile(form, path)

    arguments
        form
        path (1, :) cell
    end

    FORMS_FOLDER = fullfile(".", "forms");

    path = fullfile(FORMS_FOLDER, path{:}) + ".json";
    json.write(form, path, prettyPrint=true);

end%

