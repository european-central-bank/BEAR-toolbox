
function path = gui_getFolder()

    path = mfilename("fullpath");
    path = string(fileparts(path));

end%

