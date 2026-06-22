
function identifier = getCurrentIdentifier()

    FORM_PATH = {"identification", "selection"};

    selectionForm = gui.readFormsFile(FORM_PATH);
    identifier = gui.querySelection(form=selectionForm, count=[0, 1]);

    if isempty(identifier)
        identifier = "";
    end
    identifier = string(identifier);

end%

