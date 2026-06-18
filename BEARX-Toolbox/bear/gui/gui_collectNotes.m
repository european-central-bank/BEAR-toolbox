
function gui_collectNotes(submission)

    ftm = gui.FormToMatlab();

    submission = gui.resolveRawFormSubmission(submission);
    section = textual.fields(submission);
    newNotes = submission.(section);
    newNotes = ftm.resolveSpecialCharacters(newNotes);
    path = {section, "notes"};
    gui.writeNotesFile(newNotes, path);

    targetPage = gui.populateNotesHTML(section);
    gui.web(targetPage);

end%

