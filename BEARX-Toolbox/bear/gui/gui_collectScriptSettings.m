
function gui_collectScriptSettings(submission)

    arguments
        submission (1, 1) string
    end

    FORM_PATH = {"script", "settings"};
    HTML_END_PATH = {"html", "script", "settings.html"};

    jsonForm = gui.readFormsFile(FORM_PATH);
    cleanSubmission = gui.resolveCleanFormSubmission(submission, jsonForm);
    jsonForm = gui.updateValuesFromSubmission(jsonForm, cleanSubmission);

    % Update the estimator settings JSON with the new values
    gui.writeFormsFile(jsonForm, FORM_PATH);

    % Repopulate the script settings page
    gui.populateScriptSettingsHTML();

    % Repopulate the script listing page
    gui.populateScriptListingHTML();

    % Repopulate the script execution page
    targetPath = gui.populateScriptExecutionHTML();

    % Move on to the script execution page
    gui.web(targetPath);

end%

