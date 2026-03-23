
function gui_collectEstimatorSettings(submission)

    arguments
        submission (1, 1) string
    end

    TARGET_PAGE = {"html", "data", "source.html"};

    currentEstimator = gui.getCurrentEstimator();

    % Get information submitted by the user and cleaned up to comply with the
    % specifications
    settingsPath = {"estimation", currentEstimator};
    settingsForm = gui.readFormsFile(settingsPath);
    cleanSubmission = gui.resolveCleanFormSubmission(submission, settingsForm);
    settingsForm = gui.updateValuesFromSubmission(settingsForm, cleanSubmission);

    % Update the estimator settings JSON with the new values
    gui.writeFormsFile(settingsForm, settingsPath);

    % Repopulate the HTML with the cleaned-up settings
    gui.populateEstimatorSettingsHTML();

    % Move on to the meta settings page
    targetPage = fullfile(TARGET_PAGE{:});
    gui.web(targetPage);

end%

