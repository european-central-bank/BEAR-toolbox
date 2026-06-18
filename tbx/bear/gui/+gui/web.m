
function varargout = web(fileName)

    if ~exist(fileName, "file")
        error("HTML file '%s' does not exist.", fileName);
    end

    [varargout{1:nargout}] = web(fileName);

end%

