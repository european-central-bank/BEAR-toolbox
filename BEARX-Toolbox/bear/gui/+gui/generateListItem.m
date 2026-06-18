
function html = generateListItem(name, json, isChecked)

    if isfield(json, "show") && isequal(json.show, false)
        return
    end

    label = name;
    if isfield(json, "label") && strlength(json.label) > 0
        label = string(json.label);
    end

    checked = "";
    if isChecked
        checked = "checked";
    end

    readOnly = "";
    if isfield(json, "readonly") && isequal(json.readonly, true)
        readOnly = "disabled";
    end

    html = [
        "<input type='{TYPE}' id='{NAME}' name='{SELECTION_NAME}' value='{NAME}' {CHECKED} {READONLY}>&nbsp;", ...
        "<label for='{NAME}'>{LABEL}</label><br/>", ...
    ];

    html = replace(html, "{NAME}", name);
    html = replace(html, "{LABEL}", label);
    html = replace(html, "{CHECKED}", checked);
    html = replace(html, "{READONLY}", readOnly);

    % The following replacements are done in the calling function
    % * SELECTION_NAME
    % * TYPE
    % * ACTION

end%

