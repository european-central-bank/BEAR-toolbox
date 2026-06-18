
function nextPage = determineNextPage(formPath, contextual)

    arguments
        % Path to the form within the forms JSON file
        formPath (1, 2) cell

        % Current selection from that form
        contextual (1, 1) string = ""
    end

    guiFolder = gui_getFolder();
    nextPageMapPath = fullfile(guiFolder, "nextPageMap.json");
    nextPageMap = json.read(nextPageMapPath);

    try
        nextPage = nextPageMap.(formPath{1}).(formPath{2});
    catch
        nextPage = formPath;
        return
    end

    if isempty(nextPage{2})
        if contextual == ""
            error("Contextual information required to determine the next page.");
        end
        nextPage{2} = contextual;
    end
    nextPage = { string(nextPage{1}), string(nextPage{2}) };

end%

