function bearpath = bearroot()
bearpath = fileparts(fileparts(mfilename('fullpath')));
end