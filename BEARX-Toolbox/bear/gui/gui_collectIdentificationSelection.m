
function gui_collectIdentificationSelection(submission)

    arguments
        submission (1, 1) string
    end

    FORM_PATH = {"identification", "selection"};

    submission = gui.resolveRawFormSubmission(submission);
    newSelection = submission.selection;
    selectionForm = gui.updateSelection(FORM_PATH, newSelection);
    targetPath = cellstr(selectionForm.(newSelection).target);

    % Repopulate the identification selection HTML with the new choice
    gui.populateIdentificationSelectionHTML();

    % Move on the corresponding identification page
    targetPath = fullfile(".", "html", targetPath{:}) + ".html";
    gui.web(targetPath);

end%

