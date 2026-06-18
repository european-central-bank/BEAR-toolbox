
function table = addCustom(table, varargin)

    for i = 1 : 2 : numel(varargin)
        [name, value] = varargin{i:i+1};
        table = addprop(table, name, "table");
        table.Properties.CustomProperties.(name) = value;
    end

end%
