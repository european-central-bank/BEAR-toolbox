
function templateFolder = getTemplateFolder()

    guiFolder = gui_getFolder();
    templateFolder = fullfile(guiFolder, "templates");

end%
