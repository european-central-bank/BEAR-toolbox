
function flatNames = flattenNames(varargin)

    FLAT_SEPARATOR = "___";
    flatNames = textual.crossList(FLAT_SEPARATOR, varargin{:});

end%

