
function gui_runScript()

    scriptName = gui.getCurrentScriptName();

    commandwindow();
    run(scriptName);
    gui.returnFromCommandWindow();

end%

