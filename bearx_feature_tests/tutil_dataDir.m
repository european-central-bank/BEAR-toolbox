function d = tutil_dataDir()
%TUTIL_DATADIR  Returns absolute path of data/ subdir (created if needed).
    d = fullfile(fileparts(mfilename("fullpath")), "data");
    if ~isfolder(d), mkdir(d); end
end
