
function recreateCustomFolders()

    guiFolder = gui_getFolder();

    % Create custom forms folder
    guiFormsFolder = fullfile(guiFolder, "forms");
    customFormsFolder = fullfile(".", "forms");
    if exist(customFormsFolder, "dir")
        rmdir(customFormsFolder, "s");
    end
    copyfile(guiFormsFolder, customFormsFolder);

    % % Copy all *.json files from guiFormsFolder to customFormsFolder
    % for fileName = ["dataSettings", "metaSettings", "estimatorSettings", "selection"] + ".json"
    %     copyfile(fullfile(guiFormsFolder, fileName), fullfile(customFormsFolder, fileName));
    % end

    % Create custom tables folder
    % Do not delete existing folder because it may contain user files
    guiTablesFolder = fullfile(guiFolder, "tables");
    customTablesFolder = fullfile(".", "tables");
    copyfile(guiTablesFolder, customTablesFolder);

    % Copy all *.xlsx files from guiTablesFolder to customTablesFolder
    % for fileName = ["InstantZeros", ] + ".xlsx"
    %     copyfile(fullfile(guiTablesFolder, fileName), fullfile(customTablesFolder, fileName));
    % end

    % HTML files are recreated in resume()

end%

