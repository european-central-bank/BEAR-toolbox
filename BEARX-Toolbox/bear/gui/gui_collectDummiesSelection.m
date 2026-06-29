
function gui_collectDummiesSelection(submission)

    arguments
        submission (1, 1) string = ""
    end

    FORM_PATH = {"dummies", "selection"};
    TARGET_PAGE = {"html", "dummies", "selection.html"};

    newSelection = string.empty(1, 0);
    if ~isequal(submission, "") && ~isequal(strip(erase(submission, "?")), "")  % BEAR6-FIX: handle empty submission
        submission = gui.resolveRawFormSubmission(submission);
        newSelection = submission.selection;
    end
    gui.updateSelection(FORM_PATH, newSelection);
    gui.populateDummiesSelectionHTML();

    % Move on the general settings page
    targetPage = fullfile(".", TARGET_PAGE{:});
    gui.web(targetPage);

end%
