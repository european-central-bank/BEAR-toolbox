
function notes = readNotesFile(path)

    FORMS_FOLDER = fullfile(".", "forms");

    path = fullfile(FORMS_FOLDER, path{:}) + ".txt";
    notes = fileread(path);

    % ftm = gui.FormToMatlab();
    % notes = ftm.resolveSpecialCharacters(notes);

end%

