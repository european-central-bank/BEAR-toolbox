
function gui_collectVanillaForm(folder, fileAndSubmission, action)

    arguments
        folder (1, 1) string
        fileAndSubmission (1, 1) string = ""
        action (1, 1) string = ""
    end

    if ~ismember(nargin, [2, 3])
        error("Incorrect number of input arguments.");
    end

    if contains(fileAndSubmission, "('?")
        fileAndSubmission = strrep(fileAndSubmission, "('?", '?');
        fileAndSubmission = extractBefore(fileAndSubmission, "')");
    end

    SUBMISSION_LEAD = "?";

    file = extractBefore(fileAndSubmission, SUBMISSION_LEAD);
    submission = SUBMISSION_LEAD + extractAfter(fileAndSubmission, SUBMISSION_LEAD);
    formPath = {folder, file};

    % Get information submitted by the user and cleaned up to comply with the
    % specifications
    settingsForm = gui.readFormsFile(formPath);
    cleanSubmission = gui.resolveCleanFormSubmission(submission, settingsForm);
    settingsForm = gui.updateValuesFromSubmission(settingsForm, cleanSubmission);

    % Update the settings JSON with the new values
    gui.writeFormsFile(settingsForm, formPath);

    % Repopulate the HTML with the cleaned-up settings and possibly the custom action
    gui.populateVanillaFormHTML(formPath, action);

    % Move on to the next page
    nextPage = gui.determineNextPage(formPath);
    nextPagePath = fullfile(".", "html", nextPage{:}) + ".html";
    if ~exist(nextPagePath, "file")
        error("Target HTML file does not exist: " + nextPagePath);
    end
    gui.web(nextPagePath);

end%

