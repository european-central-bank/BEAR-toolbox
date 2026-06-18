
function gui_collectEstimatorSelection(submission)

    arguments
        submission (1, 1) string
    end

    FORM_PATH = {"estimation", "selection"};
    NEXT_PATH = {"estimation", "settings"};

    % Handle estimator selection
    submission = gui.resolveRawFormSubmission(submission);
    newSelection = submission.selection;
    selectionForm = gui.updateSelection(FORM_PATH, newSelection);
    gui.populateEstimatorSelectionHTML();

    % Determine and save the new module
    moduleMapping = gui.readFormsFile({"module", "mapping"});
    newModule = moduleMapping.(newSelection);
    gui.writeFormsFile(newModule, {"module", "selection"});

    % Prepare data source page
    gui.populateDataSourceHTML();

    % Prepare meta settings page
    gui.populateMetaSettingsHTML();

    % Prepare dummies selection page
    gui.populateDummiesSelectionHTML();

    % Prepare structural identification selection page
    gui.populateIdentificationSelectionHTML();
    % gui.populateVanillaFormHTML({"identification", "cholesky"});

    % Prepare estimator settings page with for selected estimator
    gui.populateEstimatorSettingsHTML();

    % Move on to the meta settings page
    nextPath = fullfile(".", "html", NEXT_PATH{:}) + ".html";
    gui.web(nextPath);

end%

