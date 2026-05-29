
function gui_openTable(tableName)

    if ispc()
        systemCommand = "start";
    else
        systemCommand = "open";
    end

    tablePath = fullfile("tables", string(tableName) + ".xlsx");
    systemCommandWithPath = systemCommand + " " + tablePath;
    system(systemCommandWithPath);

end%

