
function createEstimatorSettingsForms()

    GUI_FOLDER = gui_getFolder();
    FORM_FOLDER = {"forms", "estimation"};

    disp("Creating estimator settings forms...");

    modules = docgen.getModules();

    for module = modules
        estimatorClasses = docgen.getConcreteClasses(module + ".estimator");
        for qualifiedEstimatorName = estimatorClasses
            settings = docgen.getEstimatorSettings(qualifiedEstimatorName);
            %
            nameParts = split(string(qualifiedEstimatorName), ".");
            fileName = nameParts(end) + ".json";
            formPath = fullfile(GUI_FOLDER, FORM_FOLDER{:}, fileName);
            json.write(settings, formPath, prettyPrint=true);
            disp("    " + qualifiedEstimatorName);
        end
    end

end%

