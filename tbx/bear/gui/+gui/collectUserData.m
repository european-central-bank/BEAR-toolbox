function gui_collectUserData()

    % Read the URL from the web browser and parse the data
    [~,~,url] = web();

    % Extract the query string from the URL
    queryString = extractAfter(url, '?');

    % Split the query string into key-value pairs
    pairs = split(queryString, '&');

    % Initialize a structure to hold the user data
    userData = struct();
    
    % Iterate over each key-value pair
    for i = 1:numel(pairs)
        pair = split(pairs(i), '=');
        if numel(pair) == 2
            userData.(pair{1}) = pair{2};
        end
    end
    setappdata(0, 'userMetaData', userData);
end
