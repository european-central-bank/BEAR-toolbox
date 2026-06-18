% WRITE serialize MATLAB data as TOML and write to file
%
%   WRITE('file.toml', containers.Map('key', 5)) writes the text `key = 5` to
%   the file `file.toml`.
%
%   See also TOML.ENCODE, TOML.READ

function write(filename, matl_strct)
    fid = fopen(filename, 'w');
    fprintf(fid, '%s', toml.encode(matl_strct));
    fclose(fid);
end%

