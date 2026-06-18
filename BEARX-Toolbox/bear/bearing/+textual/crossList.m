
function out = crossList(glue, varargin)

    arguments
        glue (1, 1) string
    end
    arguments (Repeating)
        varargin (1, :) string
    end

    out = varargin{end};
    for x = varargin(end-1:-1:1)
        out = reshape(string(x{:}), 1, []) + glue + reshape(out, [], 1);
        out = reshape(out, 1, []);
    end

end%

