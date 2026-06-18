
function createEstimatorCategories()

    GUI_FOLDER = gui_getFolder();
    FORM_FOLDER = {"forms", "estimation"};
    CATEGORIES_FILE_PATH = fullfile(GUI_FOLDER, FORM_FOLDER{:}, "categories.json");
    SELECTION_FILE_PATH = fullfile(GUI_FOLDER, FORM_FOLDER{:}, "selection.json");

    disp("Creating estimator categories...");

    orderedCategories = [
        "Plain estimators", ...
        "Time-varying estimators", ...
        "Panel estimators with separable units", ...
        "Panel estimators with cross-unit dependence", ...
        "One-step factor-augmented estimators", ...
        "Two-step factor-augmented estimators", ...
        "Time-varying factor-augmented estimators", ...
        "Specialized estimators", ...
    ];

    selection = json.read(SELECTION_FILE_PATH);
    checkCategories = string.empty(1, 0);
    for n = textual.fields(selection)
        checkCategories(end+1) = selection.(n).category;
    end
    checkCategories = unique(checkCategories);

    if ~isequal(sort(orderedCategories), sort(checkCategories))
        error("Categories in selection.json do not match ordered categories.");
    end

    for n = orderedCategories
        disp("    " + n);
    end

    orderedCategories = cellstr(orderedCategories);
    json.write(orderedCategories, CATEGORIES_FILE_PATH, prettyPrint=true);

end%

