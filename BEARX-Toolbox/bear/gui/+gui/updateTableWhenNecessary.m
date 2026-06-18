
function updateTableWhenNecessary(options)

    arguments
        options.RowNames (1, :) string
        options.ColumnNames (1, :) string
        options.FileName (1, 1) string
        options.Title (1, 1) string
        options.WriteMode (1, 1) = "overwritesheet"
    end

    guiFolder = gui_getFolder();
    sourceFile = fullfile(guiFolder, options.FileName);
    targetFile = fullfile(".", options.FileName);

    if ~needsUpdate_(targetFile, options.RowNames, options.ColumnNames)
        % Update not necessary because the rows and columns of the existing
        % table are already correct
        return
    end

    % Update the table; this will erase the existing content
    numRows = numel(options.RowNames);
    numColumns = numel(options.ColumnNames);
    content = repmat("", numRows+1, numColumns+1);
    content(1, 1) = options.Title;
    content(1, 2:end) = options.ColumnNames;
    content(2:end, 1) = transpose(options.RowNames);

    copyfile(sourceFile, targetFile);
    writematrix( ...
        content, targetFile ...
        , fileType="spreadsheet" ...
        , writeMode=options.WriteMode ...
    );

end%


function out = needsUpdate_(targetFile, rowNames, columnNames)

    if ~isfile(targetFile)
        out = true;
        return
    end

    existingTable = readmatrix( ...
        targetFile ...
        , fileType="spreadsheet" ...
        , outputType="string" ...
    );

    needsNumRows = numel(rowNames) + 1;
    needsNumColumns = numel(columnNames) + 1;
    if size(existingTable, 1) ~= needsNumRows || size(existingTable, 2) ~= needsNumColumns
        out = true;
        return
    end

    if any(reshape(existingTable(2:end, 1), 1, []) ~= rowNames)
        out = true;
        return
    end

    if any(reshape(existingTable(1, 2:end), 1, []) ~= columnNames)
        out = true;
        return
    end

    out = false;

end%

