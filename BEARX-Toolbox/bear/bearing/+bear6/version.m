
function v = version()
    thisDir = fileparts(mfilename("fullpath"));
    versionFile = fullfile(thisDir, "version");
    v = string(fileread(versionFile));
end%

