
function [tt, freq] = fromStruct(s, varargin)

    if iscell(s)
        s = struct(s{:});
    end
    t = struct2table(s);
    [tt, freq] = tablex.fromTable(t, varargin{:});

end%

