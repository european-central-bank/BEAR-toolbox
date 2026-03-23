
function json = read(fileName)

    file = string(fileread(fileName));
    json = jsondecode(file);

end%

