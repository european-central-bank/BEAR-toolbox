
function htmlForm = generateCategorizedButtons(jsonForm, currentSelection, categories, action)

    arguments
        % Selection form including current values
        jsonForm (1, 1) struct

        % List of currently selected names
        currentSelection (1, :) string

        % Ordered list of categories to display
        categories (1, :) string

        % Callback action to invoke on submission
        action (1, 1) string
    end

    SELECTION_NAME = "selection";
    TYPE = "radio";

    categories = unique(categories, "stable");

    if isequal(currentSelection, "")
        currentSelection = string.empty(1, 0);
    end

    submitButton = gui.generateSubmitButton();

    htmlForm = string.empty(1, 0);
    htmlForm(end+1) = "<br/>";
    htmlForm(end+1) = "<form action='matlab:{ACTION}'>";
    htmlForm(end+1) = submitButton;

    % Compile lists of names in each category
    numCategories = numel(categories);
    namesInCategory = repmat({string.empty(1, 0)}, 1, numCategories);
    for name = textual.fields(jsonForm)
        item = jsonForm.(name);
        cat = string(item.category);
        inx = cat == categories;
        if ~any(inx)
            continue
        end
        namesInCategory{inx}(1, end+1) = name;
    end

    for i = 1 : numCategories
        % Heading for category
        htmlForm(end+1) = "<h3>" + categories(i) + "</h3>"; %#ok<AGROW>
        %
        % Buttons for each name in category
        for name = namesInCategory{i}
            isChecked = ismember(name, currentSelection);
            add = gui.generateListItem(name, jsonForm.(name), isChecked);
            add = replace(add, "{SELECTION_NAME}", SELECTION_NAME);
            htmlForm = [htmlForm, add]; %#ok<AGROW>
        end
    end

    htmlForm = replace(htmlForm, "{ACTION}", action);
    htmlForm = replace(htmlForm, "{TYPE}", TYPE);

    htmlForm(end+1) = "<br/>";
    htmlForm(end+1) = submitButton;
    htmlForm(end+1) = "</form>";
    htmlForm(end+1) = "<br/>";

    htmlForm = join(htmlForm, newline());

end%

