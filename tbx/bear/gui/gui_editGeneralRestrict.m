
function gui_editGeneralRestrict(fileName)
    returnTo = fullfile("html", "identification", "GeneralRestrict.html");
    gui.returnFromCommandWindow(returnTo);
    commandwindow();
    edit(fullfile("tables", "GeneralRestrict.md"));
end%

