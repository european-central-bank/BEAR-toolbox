
function filePath = getCurrentDataFilePath(field)

    dataSource = gui.getCurrentDataSource();
    filePath = string(dataSource.(field).value);

    if ~isscalar(filePath)
        filePath = "";
        return
    end

    if ismissing(filePath)
        filePath = "";
        return
    end

end%

