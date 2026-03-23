
function gui_collectTasksSelection(submission)

    arguments
        submission (1, 1) string = ""
    end

    FORM_PATH = {"tasks", "selection"};
    TARGET_PAGE = {"html", "tasks", "prerequisites.html"};

    newSelection = string.empty(1, 0);
    if ~isequal(submission, "")
        submission = gui.resolveRawFormSubmission(submission);
        newSelection = submission.selection;
    end
    gui.updateSelection(FORM_PATH, newSelection);
    gui.populateTasksSelectionHTML();

    % Move on the prerequisites page
    targetPage = fullfile(".", TARGET_PAGE{:});
    gui.web(targetPage);

end%
