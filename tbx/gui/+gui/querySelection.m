
function selected = querySelection(options)

    arguments
        options.path (1, :) cell = cell.empty(1, 0)
        options.form (1, 1) struct = struct.empty(1, 0)
        options.count (1, :) double = []
    end

    if ~isempty(options.form)
        form = options.form;
    else
        form = gui.readFormsFile(path);
    end

    selected = string.empty(1, 0);
    for n = textual.fields(form)
        if ~isequal(form.(n).value, true)
            continue
        end
        selected(end+1) = string(n); %#ok<AGROW>
    end

    if ~isempty(options.count)
        numSelected = numel(selected);
        if ~any(numSelected == options.count)
            numExpected = join(string(options.count), " or ");
            error("Invalid number of selections: expected %s, got %g", numExpected, numSelected);
        end
    end

end%

