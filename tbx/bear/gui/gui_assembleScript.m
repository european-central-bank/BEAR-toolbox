
function gui_assembleScript()

    TARGET_PAGE = {"html", "script", "execution.html"};

    scriptName = gui.getCurrentScriptName();
    scriptSettings = gui.getCurrentScriptSettings();

    if exist(scriptName, "file") && ~scriptSettings.OverwriteExisting
        error("Script already exists. To overwrite, enable the overwrite option in the script form.");
    end

    scripter.assemble(saveToFile=scriptName);

    % Repopulate the script listing page
    gui.populateScriptListingHTML();

    % Stay on the script execution page
    targetPage = fullfile(".", TARGET_PAGE{:});
    gui.web(targetPage);

end%

