
function selectionForm = updateSelection(formPath, newSelection)

    arguments
        formPath (1, :) cell
        newSelection (1, :) string
    end

    selectionForm = gui.readFormsFile(formPath);

    for key = textual.fields(selectionForm)
        newValue = any(key == newSelection);
        selectionForm.(key).value = newValue;
    end

    gui.writeFormsFile(selectionForm, formPath);

end%

