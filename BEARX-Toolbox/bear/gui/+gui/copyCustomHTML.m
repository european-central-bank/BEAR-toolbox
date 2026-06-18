
function copyCustomHTML(sourceFilename, targetFilename, varargin)

    x = fileread(sourceFilename);

    if ~isempty(varargin) && isa(varargin{1}, "function_handle")
        transformFunc = varargin{1};
        varargin = varargin(2:end);
        x = transformFunc(x);
    end

    for i = 1 : 2 : numel(varargin)
        oldText = varargin{i};
        newText = varargin{i+1};
        x = replace(x, oldText, newText);
    end

    writematrix(x, targetFilename, fileType="text", quoteStrings=false);

end%

