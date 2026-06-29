
function write(jsonable, fileName, options)

    arguments
        jsonable
        fileName (1, 1) string
        options.PrettyPrint logical = false
    end

    % if ~isstring(jsonable)
    %     jsonable = jsonencode(jsonable, "PrettyPrint", options.PrettyPrint);
    % end
    jsonable = jsonencode(jsonable, "PrettyPrint", options.PrettyPrint);

    writematrix( ...
        jsonable, fileName ...
        , fileType="text" ...
        , quoteStrings=false ...
    );

end%

