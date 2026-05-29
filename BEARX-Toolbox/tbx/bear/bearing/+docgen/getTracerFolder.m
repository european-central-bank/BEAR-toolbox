
function path = getTracerFolder(package)

    COMMENT_START = " %";

    path = string(which(package + ".Tracer"));
    if contains(path, COMMENT_START)
        path = strip(extractBefore(path, COMMENT_START));
    end
    path = fileparts(path);

end%

