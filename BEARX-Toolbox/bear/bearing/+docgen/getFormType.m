
function formType = getFormType(type, dim)

    % Check type
    switch type
        case "double"
            formType = "number";
        case "logical"
            formType = "logical";
        case "string"
            formType = "name";
        case "char"
            formType = "name";
        case "function_handle"
            formType = "string";
        case "datetime"
            formType = "date";
        otherwise
            error("Unknown type for estimator settings forms: " + type);
    end

    % Check dimension
    if ~isempty(dim)
        if numel(dim) > 1
            if isnumeric([dim{:}]) && formType == "numeric"
                formType ;
            elseif isnumeric([dim{:}])
                formType = formType;
            elseif isnumeric(dim{1}) 
                formType = formType + "s";
            elseif isnumeric(dim{2})
                formType = formType + "s";
            else
                formType = formType + "s";
            end
        else
            formType = formType + "s";
        end
    end

end%

