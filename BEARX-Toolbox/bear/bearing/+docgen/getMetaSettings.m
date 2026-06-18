function out = getMetaSettings()
% getMetaSettings  Get the metadata settings for the documentation generator

    ModelDir = docgen.getDirectory("model.Tracer");
    files = dir(fullfile(ModelDir, "Meta.m"));
    out = struct();
    name = extractBefore(files.name, ".m");

    try
        modelMC = eval(['?' 'model.' name]);
    catch
        modelMC = struct();
        modelMC.PropertyList = [];
    end

    % collect the properties of the model class
    props = reshape(modelMC.PropertyList, 1, []);

    for prop = props
        prop = props(i);
        if prop.Hidden || prop.Constant || prop.Dependent
            continue
        end
        % collect default value
        if prop.HasDefault
            defaultValue = prop.DefaultValue;
        else
            defaultValue = '';
        end
        % Deal with the function handler as a dirty fix for now
        if isa(defaultValue, 'function_handle')
            defaultValue = 'function handle';
        end

        % collect type
        if isempty(prop.Validation) && ~prop.HasDefault
            Type = "unknown";
        else
            Type = prop.Validation.Class.Name;
        end

        % collect Size
        if isempty(prop.Validation)
            sz = '';
        else
            sz = prop.Validation.Size;
        end
        len = length(sz);
        dim = cell(1:len);
        for k = 1:len
            if isa(sz(k),'meta.FixedDimension')
                dim{k} = sz(k).Length;
            else
                dim{k} = ':';
            end
        end
        if isempty(dim)
            dim = '';
        end

        type = docgen.getTypeTaxonomy(Type, dim);

        out.(prop.Name) = struct(...
            value=defaultValue, ...
            type=type, ...
            Description=prop.Description ...
        );
    end

end
