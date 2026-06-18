
function updateCurrentSelectionWithinCustomHTML(filePath, currentSelection)

    arguments
        filePath (1, 1) string
        currentSelection (1, 1) string
    end

    x = fileread(filePath);

    START = "<!-- START CURRENT SELECTION -->";
    END = "<!-- END CURRENT SELECTION -->";

    currentSelection = START + currentSelection + END;
    x = regexprep(x, START + ".*?" + END, currentSelection);

    writematrix(x, filePath, fileType="text", quoteStrings=false);

end%

