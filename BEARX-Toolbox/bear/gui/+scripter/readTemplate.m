
function code = readTemplate(templateName)

    arguments
        templateName (1, 1) string
    end

    templateFolder = scripter.getTemplateFolder();
    preambleFile = fullfile(templateFolder, templateName + ".m");
    code = textual.read(preambleFile);

end%

