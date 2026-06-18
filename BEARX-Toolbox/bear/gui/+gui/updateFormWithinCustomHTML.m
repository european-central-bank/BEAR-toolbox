
function updateFormWithinCustomHTML(filePath, form)

    arguments
        filePath (1, 1) string
        form (1, 1) string
    end

    x = fileread(filePath);

    START = "<!-- START FORM -->";
    END = "<!-- END FORM -->";

    form = START + newline() + form + newline() + END;
    x = regexprep(x, START + ".*?" + END, form);

    writematrix(x, filePath, fileType="text", quoteStrings=false);

end%

