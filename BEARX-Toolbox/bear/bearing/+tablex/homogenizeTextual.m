
function tbl = homogenizeTextual(tbl)
    arguments
        tbl (:, :) table
    end
    %
    data = tbl{:, :};
    data = strip(string(data));
    data(ismissing(data)) = "";
    tbl{:, :} = data;
end%

