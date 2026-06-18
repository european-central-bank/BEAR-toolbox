
function nonuniqueList = nonunique(inputList)
    nonuniqueList = string.empty(1, 0);
    for n = textual.stringify(inputList)
        if nnz(inputList == n) > 1
            nonuniqueList(end+1) = n;
        end
    end
    nonuniqueList = unique(nonuniqueList, "stable");
end%

