
function init = ensureDim(init, numInit, data)
    if isempty(init)
        init = NaN;
    end
    sizeInit = size(init);
    ndimsData = ndims(data);
    if numInit > 0 && sizeInit(1) == 1
        init = repmat(init, [numInit, ones(1, ndimsData-1)]);
    end
    if prod(sizeInit(2:end)) == 1
        sizeData = size(data);
        init = repmat(init, [1, sizeData(2:end)]);
    end
    sizeInit = size(init);
    higherDim = repmat({':'}, 1, ndimsData-1);
    init = init(end-numInit+1:end, higherDim{:});
end%

