
function targetPath = populateScriptExecutionHTML()

    HTML_END_PATH = {"html", "script", "execution.html"};

    scriptName = gui.getCurrentScriptName();
    if scriptName == ""
        scriptName = "[No valid script name selected]";
    end

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});

    gui.copyCustomHTML( ...
        sourcePath, targetPath, ...
        "?SCRIPT_NAME?", scriptName ...
    );

end%

