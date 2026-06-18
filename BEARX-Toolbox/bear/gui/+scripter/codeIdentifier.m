
function code = codeIdentifier()

    identifier = gui.getCurrentIdentifier();
    settings = gui.getCurrentIdentifierSettings();

    place = struct();
    place.IDENTIFIER = string(identifier);
    place.SETTINGS = scripter.printFormAsSettings(settings);

    code = scripter.readTemplate("identifier");
    code = scripter.replaceInCode(code, place);

end%

