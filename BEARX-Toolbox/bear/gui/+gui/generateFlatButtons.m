
function htmlForm = generateFlatButtons(jsonForm, currentSelection, action, options)

    arguments
        % Selection form including current values
        jsonForm (1, 1) struct

        % List of currently selected names
        currentSelection (1, :) string

        % Callback action to invoke on submission
        action (1, 1) string

        % Type of buttons to generate: "radio" or "checkbox"
        options.type (1, 1) string {ismember(options.type, ["radio", "checkbox"])} = "radio"
    end

    SELECTION_NAME = "selection";

    submitButton = gui.generateSubmitButton();

    htmlForm = string.empty(1, 0);
    htmlForm(end+1) = "<br/>";
    htmlForm(end+1) = "<form action='matlab:{ACTION}'>";

    htmlForm(end+1) = submitButton;
    htmlForm(end+1) = "<br/><br/>";

    for name = textual.fields(jsonForm)
        isChecked = ismember(name, currentSelection);
        add = gui.generateListItem(name, jsonForm.(name), isChecked);
        add = replace(add, "{SELECTION_NAME}", SELECTION_NAME);
        htmlForm = [htmlForm, add]; %#ok<AGROW>
    end

    htmlForm = replace(htmlForm, "{ACTION}", action);
    htmlForm = replace(htmlForm, "{TYPE}", options.type);

    htmlForm(end+1) = "<br/>";
    htmlForm(end+1) = submitButton;
    htmlForm(end+1) = "</form>";
    htmlForm(end+1) = "<br/>";

    htmlForm = join(htmlForm, newline());

end%

