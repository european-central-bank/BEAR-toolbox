function [med] = calcMedian(inputArray,variablename)

    values = cellfun(@(x) x.(variablename)(:), inputArray.Presampled, 'UniformOutput', false);
    matrix = horzcat(values{:});
    med = median(matrix, 2);

end