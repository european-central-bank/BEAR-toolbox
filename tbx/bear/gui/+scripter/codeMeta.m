
function code = codeMeta()

    metaSettings = gui.getCurrentMetaSettings();

    place = struct();
    place.META_SETTINGS = scripter.printFormAsSettings(metaSettings);

    % Create the code from the template
    code = scripter.readTemplate("meta");
    code = scripter.replaceInCode(code, place);

end%

