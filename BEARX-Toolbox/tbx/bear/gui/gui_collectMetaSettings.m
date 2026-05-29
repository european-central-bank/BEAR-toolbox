
function gui_collectMetaSettings(submission)

    arguments
        submission (1, 1) string
    end

    NEXT_PAGE = {"meta", "settings"};

    % Determine the current module and the path to the corresponding meta
    % settings form
    currentModule = gui.getCurrentModule();
    settingsPath = {"meta", currentModule};

    % Get information submitted by the user and cleaned up to comply with the
    % specifications
    settingsForm = gui.readFormsFile(settingsPath);
    cleanSubmission = gui.resolveCleanFormSubmission(submission, settingsForm);
    settingsForm = gui.updateValuesFromSubmission(settingsForm, cleanSubmission);

    % Update the meta settings JSON with the new values
    gui.writeFormsFile(settingsForm, settingsPath);

    % Update tables if there has been changes in the relevant meta settings
    gui.updateLongRunDummiesTable();
    gui.updateInstantZerosTable();
    gui.updateIneqRestrictTable();
    gui.updateConditioningDataTable();
    gui.updateConditioningPlanTable();

    % Repopulate the structural identification selection page
    % gui.populateIdentificationSelectionHTML();

    % Repopulate the HTML with the cleaned-up settings
    gui.populateMetaSettingsHTML();

    % Move on to the structural identification selection page
    nextPage = fullfile(".", "html", NEXT_PAGE{:}) + ".html";
    gui.web(nextPage);

end%

