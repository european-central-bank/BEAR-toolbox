function outputString = createTable(inputStruct, Header)
% Create a string representation of a table from a structure. To be used in HTML

    lines = string.empty(0, 1);
    fieldNames = fieldnames(inputStruct);
    numFields = numel(fieldNames);
    if numFields == 0
        outputString = "No data available.";
        return;
    end

    fieldNames = textual.stringify(fieldNames);
    fieldNames = sort(fieldNames);

    lines(end+1) = "<h2>"+Header+"</h2>";
    lines(end+1) = "<table>";
    lines(end+1) = "<thead>";
    lines(end+1) = "<tr>";
    lines(end+1) = "<th>Name</th>";
    lines(end+1) = "</tr>";
    lines(end+1) = "</thead>";
    lines(end+1) = "<tbody>";
    % Iterate over field names to create table rows
    for i = 1:numFields
        fieldName = fieldNames{i};
        lines(end+1) = "<tr>";
        lines(end+1) = "<td><code>" + fieldName + "</code></td>";
        lines(end+1) = "</tr>";
    end
    lines(end+1) = "</tbody>";
    lines(end+1) = "</table>";
    outputString = join(lines, newline());
end