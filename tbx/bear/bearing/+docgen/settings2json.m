
function out = settings2json()

    % clear cache of all classes
    clear classes
    rehash path

    currentDir = fileparts(mfilename("fullpath"));
    sandboxDir = fileparts(currentDir);
    settingsDir = fullfile(sandboxDir, "gui", "settings");

    write_ = @(content, fileName) json.write( ...
        content, ...
        fullfile(settingsDir, fileName), ...
        prettyPrint=true ...
    );

    estimatorSettings = docgen.getEstimatorSettings();
    write_(estimatorSettings, "estimatorSettings.json");

    estimatorCategories = docgen.getEstimatorCategories();
    estimatorSelection = struct();
    estimatorSelection.Choices = estimatorCategories;
    estimatorSelection.Selection = [];
    write_(estimatorSelection, "estimatorSelection.json");

    metaSettings = docgen.getMetaSettings();
    write_(metaSettings, "metaSettings.json");

    dataSettings = struct();
    dataSettings.FileName.value = "";
    dataSettings.FileName.type = "string";
    write_(dataSettings, "dataSettings.json");

end%

