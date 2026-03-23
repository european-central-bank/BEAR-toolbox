
function targetFile = populateNotesHTML(section)

    try
        notes = gui.readNotesFile({section, "notes"});
    catch
        notes = "";
    end
    htmlNotes = gui.generateTextArea(section, notes, "gui_collectNotes");

    guiFolder = gui_getFolder();
    if isequal(section, "home")
        endPath = {"html", "notes.html"};
    else
        endPath = {"html", section, "notes.html"};
    end
    sourceFile = fullfile(guiFolder, endPath{:});
    targetFile = fullfile(".", endPath{:});

    gui.copyCustomHTML(sourceFile, targetFile, "?NOTES?", htmlNotes);

end%

