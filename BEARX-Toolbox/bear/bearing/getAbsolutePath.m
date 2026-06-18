
function absPath = getAbsolutePath(varargin)

    refFolder = getReferenceFolder();
    absPath = fullfile(refFolder, varargin{:});

end%

