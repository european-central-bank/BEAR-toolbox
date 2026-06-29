
function out = getDirectory(something)

    out = which(something);
    if contains(out, "%")
        out = extractBefore(out, "%");
    end
    out = fileparts(out);

end%

