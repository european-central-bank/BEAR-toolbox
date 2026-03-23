
function createFolder(folderPath)

    if ~exist(folderPath, "dir")
        mkdir(folderPath);
    end

end%

