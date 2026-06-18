
function list = listCategories(estimatorCategories)

    list = string.empty(0, 1);
    for n = reshape(string(fieldnames(estimatorCategories)), 1, [])
        list(end+1) = estimatorCategories.(n);
    end
    list = unique(list, 'stable');

end%

