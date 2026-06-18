

function settings = getEstimatorSettings(qualifiedEstimatorName)

    estimatorObject = eval(qualifiedEstimatorName);
    settingsObject = estimatorObject.Settings;
    settingsMetaclass = metaclass(settingsObject);

    settings = struct();

    for i = 1 : numel(settingsMetaclass.PropertyList)

        prop = settingsMetaclass.PropertyList(i);
        name = prop.Name;

        if prop.Hidden || prop.Constant
            continue
        end

        % collect default value
        if prop.HasDefault
            defaultValue = prop.DefaultValue;
        else 
            defaultValue = "";
        end

        % Deal with the function handler as a dirty fix for now
        if isa(defaultValue, "function_handle")
            defaultValue = "function handle";
        end

        % collect type
        if isempty(prop.Validation)
            type = class(defaultValue);
        else
            type = prop.Validation.Class.Name;
        end

        % collect Size
        if isempty(prop.Validation)
            size_ = "";
        else
            size_ = prop.Validation.Size;
        end
        numDims = numel(size_);
        dim = cell(1, numDims);
        for k = 1 : numDims
            if isa(size_(k), "meta.FixedDimension") 
                dim{k} = size_(k).Length;
            else
                dim{k} = ":";
            end
        end
        if numDims == 0
            dim = "";
        end

        try
            formType = docgen.getFormType(type, dim);
        catch
            keyboard
        end
        dim = "[" + join(textual.stringify(dim),",") + "]";

        details = strip(string(prop.DetailedDescription));

        % settings.(prop.Name) = {prop.Description, defaultValue, type, dim, formType, prop.DetailedDescription};
        settings.(name) = struct( ...
            label=prop.Description, ...
            type=formType, ...
            value=defaultValue, ...
            details=details ...
        );
    end

    % try 
    %     estimatorReference = estimator.(estimatorClassName).getModelReference();
    % catch
    %     estimatorReference = [];
    % end

    % if ~isempty(estimatorReference) && isfield(estimatorReference, "category")
    %     out.(estimatorReference.category).(estimatorClassName).settings = settings;
    %     out.(estimatorReference.category).(estimatorClassName).description = estimatorMC.Description;
    %     out.(estimatorReference.category).(estimatorClassName).detailedDesc = estimatorMC.DetailedDescription;
    % end

end%

