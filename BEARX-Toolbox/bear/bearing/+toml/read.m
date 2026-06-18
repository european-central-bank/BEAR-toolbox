% READ parse TOML data from a file
%
%   READ('file.toml') loads the contents of `file.toml` and parses
%   that data into a MATLAB Map.
%
%   See also FILEREAD, TOML.DECODE

function struct_data = read(filename)

    fid = fopen(filename, 'r', 'n', 'UTF-8');
    raw_text = fread(fid, [1, inf], '*char');
    map_data = toml.decode(raw_text);
    struct_data = toml.map_to_struct(map_data);

end%

