% STRUCT_TO_MAP convert a struct to a (possibly nested) containers.Map object
%
%   STRUCT_TO_MAP(my_struct) returns an ordered map with the same keys and corresponding
%   values as `my_struct`, recursively converting struct values likewise. Any keys
%   that are not already valid MATLAB identifiers will be preserved as is.

function map = struct_to_map(struct)
    if isstruct(struct)
        map = containers.Map();
        fields = fieldnames(struct);
        for i = 1 : numel(fields)
            key = fields{i};
            value = toml.struct_to_map(struct.(key));
            map(key) = value;
        end
    elseif iscell(struct)
        map = cell(size(struct));
        for i = 1 : numel(struct)
            map{i} = toml.struct_to_map(struct{i});
        end
    else
        map = struct;
    end
end