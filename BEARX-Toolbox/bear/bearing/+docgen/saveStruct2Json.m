function saveStruct2Json(settings, jsonFilePath)
    jsonStr = jsonencode(settings, ...
        'PrettyPrint', true);
    % save the JSON string to a file
    fid = fopen(jsonFilePath, 'w');
    if fid == -1
        error('Could not open file %s for writing.', jsonFilePath);
    end
    fprintf(fid, '%s', jsonStr);
    fclose(fid);
end