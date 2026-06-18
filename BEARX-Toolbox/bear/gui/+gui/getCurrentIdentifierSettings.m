
function settings = getCurrentIdentifierSettings()

    identifier = gui.getCurrentIdentifier();

    if identifier == ""
        settings = [];
        return
    end

    path = {"identification", identifier};
    settings = gui.readFormsFile(path);

end%

