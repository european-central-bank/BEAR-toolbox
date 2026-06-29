
function populateVanillaFormHTML(formPath, action)

    arguments
        formPath (1, 2) cell
        action (1, 1) string = ""
    end

    formPath = { string(formPath{1}), string(formPath{2}) };
    htmlEndPath = {"html", formPath{1}, formPath{2} + ".html"};

    if isequal(action, "")
        action = "gui_collectVanillaForm " + formPath{1} + " " + formPath{2};
    end

    % if ~endsWith(action, " ")
    %     action = action + " ";
    % end

    form = gui.readFormsFile(formPath);
    htmlForm = gui.generateFreeForm(form, action=action);

    gui.updateFormWithinCustomHTML(fullfile(".", htmlEndPath{:}), htmlForm);

end%

