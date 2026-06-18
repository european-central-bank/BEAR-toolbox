
function createEstimatorSelectionForm()

    GUI_FOLDER = gui_getFolder();
    FORM_FOLDER = {"forms", "estimation"};
    FILE_PATH = fullfile(GUI_FOLDER, FORM_FOLDER{:}, "selection.json");

    disp("Creating estimator selection form...");

    modules = docgen.getModules();
    selection = struct();
    for module = modules
        [qualifiedEstimatorNames, shortNames] = docgen.getConcreteClasses(module + ".estimator");
        for i = 1 : numel(shortNames)
            shortName = shortNames(i);
            klass = eval(qualifiedEstimatorNames(i));
            category = klass.Category;
            label = string(klass.Description) + " (<code>" + shortName + "</code>)";
            disp("    " + qualifiedEstimatorNames(i) + "-->" + category);
            selection.(shortName) = struct( ...
                label=label, ...
                category=category, ...
                value=false, ...
                target=["estimation", shortName] ...
            );
        end
    end

    json.write(selection, FILE_PATH, prettyPrint=true);

end%

