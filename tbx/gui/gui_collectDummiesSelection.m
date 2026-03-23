
function gui_collectDummiesSelection(submission)

    arguments
        submission (1, 1) string = ""
    end

    FORM_PATH = {"dummies", "selection"};
    TARGET_PAGE = {"html", "dummies", "selection.html"};

    newSelection = string.empty(1, 0);
    if ~isequal(submission, "")
        submission = gui.resolveRawFormSubmission(submission);
        newSelection = submission.selection;
    end
    gui.updateSelection(FORM_PATH, newSelection);
    gui.populateDummiesSelectionHTML();

    % Move on the prerequisites page
    targetPage = fullfile(".", TARGET_PAGE{:});
    gui.web(targetPage);

end%
