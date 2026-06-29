
function code = printFormAsSettings(form, options)

    arguments
        form (1, 1) struct
        options.indent (1, 1) double = 4
        options.excludeNames (1, :) string = string.empty(1, 0)
        options.argsBefore (1, 1) logical = true
    end

    mts = gui.MatlabToScript();
    INDENT = string(repmat(' ', 1, options.indent));

    code = string.empty(0, 1);

    for name = textual.fields(form)
        if ismember(name, options.excludeNames)
            continue
        end
        value = form.(name).value;
        type = form.(name).type;
        valueString = mts.(type)(value);
        code(end+1, 1) = sprintf("%s=%s ...", name, valueString); %#ok<AGROW>
    end

    inxIndent = 2 : numel(code);
    code(inxIndent) = INDENT + ", " + code(inxIndent);

    code = join(code, newline());

end%

