
function outputString = generateFreeForm(inputStruct, options)

    arguments
        inputStruct (1, 1) struct
        %
        options.header (1, 1) string = ""
        options.action (1, 1) string = ""
        options.getFields = @textual.fields
    end

    ELEMENT_CREATORS = struct(...
        name=@createTextField_, ...
        names=@createLongTextField_, ...
        string=@createTextField_, ...
        number=@createTextField_, ...
        numbers=@createTextField_, ...
        date=@createTextField_, ...
        logical=@createCheckbox_, ...
        logicals=@createTextField_, ...
        dates=@createTextField_, ...
        span=@createTextField_, ...
        filename=@createFile_ ...
    );

    mtf = gui.MatlabToForm;

    submitButton = gui.generateSubmitButton();

    fieldNames = options.getFields(inputStruct);

    needsHeader = strlength(options.header) > 0;

    html = string.empty(1, 0);

    if needsHeader
        html(end+1) = "<h2>" + options.header + "</h2>";
    end

    html(end+1) = "<br/>";
    html(end+1) = "<form action='matlab:" + options.action + "'>";
    html(end+1) = submitButton;
    html(end+1) = "<br/>";
    html(end+1) = "<br/>";

    for name = fieldNames
        item = inputStruct.(name);
        if isfield(item, "show") && isequal(item.show, false)
            continue
        end
        if isfield(item, "label") && strlength(string(item.label)) > 0
            label = string(item.label);
        else
            label = name;
        end
        type = item.type;
        matlabValue = item.value;
        formValue = mtf.(type)(matlabValue);
        elementCreator = ELEMENT_CREATORS.(type);
        elementLines = elementCreator(name, formValue, label);
        html = [html, elementLines]; %#ok<AGROW>
    end

    html(end+1) = "<br/>";
    html(end+1) = submitButton;
    html(end+1) = "</form>";
    html(end+1) = "<br/>";

    outputString = join(html, newline());

end%


function html = createTextField_(name, value, label, size)
    arguments
        name (1, 1) string
        value (1, 1) string
        label (1, 1) string
        size (1, 1) double = 20
    end
    html = join([
        "<label for='{NAME}'>{LABEL}</label><br/>"
        "<input style='color:black; background-color:lightgray' type='text' id='{NAME}' name='{NAME}' value='{VALUE}' size='{SIZE}'><br/>"
    ], newline());
    html = replace(html, "{NAME}", name);
    html = replace(html, "{VALUE}", value);
    html = replace(html, "{LABEL}", label);
    html = replace(html, "{SIZE}", string(size));
end%


function html = createLongTextField_(name, value, label)
    html = createTextField_(name, value, label, 60);
end%


function html = createFile_(name, value, label)
    html = join([
        "<label for='{NAME}'>{LABEL}</label><br/>"
        "<input style='color:black; background-color:lightgray' type='file' id='{NAME}' name='{NAME}' value='{VALUE}'><br/>"
    ], newline());
    html = replace(html, "{NAME}", name);
    html = replace(html, "{VALUE}", value);
    html = replace(html, "{LABEL}", label);
end%


function html = createCheckbox_(name, value, label)
    html = string.empty(0, 1);
    checked = "";
    if gui.isTrue(value)
        checked = "checked";
    end
    html(end+1) = sprintf("<input style='margin-top:1em; margin-bottom:1em; margin-left:-0.1em' type='checkbox' id='%s' name='%s' value='true' %s>&nbsp;", name, name, checked);
    html(end+1) = sprintf("<label for='%s'>%s</label><br/>", name, label);
end%

