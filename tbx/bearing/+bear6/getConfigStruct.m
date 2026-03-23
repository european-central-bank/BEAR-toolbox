
function config = getConfigStruct(options)

    arguments
        options.ConfigFile (1, 1) string
        options.ConfigStruct (1, 1) struct
    end

    if isfield(options, "ConfigStruct") && ~isempty(options.ConfigStruct)
        config = options.ConfigStruct;
        return
    end
    if isfield(options, "ConfigFile") && ~isempty(options.ConfigFile)
        config = toml.read(options.ConfigFile);
        return
    end

end%
