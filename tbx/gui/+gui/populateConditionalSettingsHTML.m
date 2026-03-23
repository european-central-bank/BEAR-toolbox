
function populateConditionalSettingsHTML()

    gui.populateVanillaFormHTML({"tasks", "conditional"}, "gui_collectConditionalSettings ");

    currentFolder = pwd();
    htmlPath = fullfile(".", "html", "tasks", "conditional.html");
    gui.copyCustomHTML( ...
        htmlPath, htmlPath ...
        , "?DATA_PATH?", fullfile(currentFolder, "tables", "ConditioningData.xlsx") ...
        , "?PLAN_PATH?", fullfile(currentFolder, "tables", "ConditioningPlan.xlsx") ...
    );

end%

