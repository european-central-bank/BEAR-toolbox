
function gui_editScript()

    scriptName = gui.getCurrentScriptName();

    commandwindow();
    edit(scriptName);
    gui.returnFromCommandWindow();

end%

