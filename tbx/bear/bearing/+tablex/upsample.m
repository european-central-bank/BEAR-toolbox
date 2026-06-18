
function highTbl = upsample(lowTbl, highFreq, options)

    arguments
        lowTbl timetable
        highFreq (1, 1) double {mustBeMember(highFreq, [1, 4, 12])}
        options.method = "flat"
        options.downscale = false
    end

    lowFreq = tablex.frequency(lowTbl);

    if lowFreq == highFreq
        highTbl = lowTbl;
        return
    end

    if lowFreq > highFreq
        error("Cannot upsample from frequency %d to frequency %d.", lowFreq, highFreq);
    end

    freqFactor = highFreq / lowFreq;
    if freqFactor ~= round(freqFactor)
        error("Cannot upsample from frequency %d to frequency %d.", lowFreq, highFreq);
    end

    lowHandler = datex.getFrequencyHandler(lowFreq);
    highHandler = datex.getFrequencyHandler(highFreq);

    names = tablex.names(lowTbl);
    lowSpan = tablex.span(lowTbl);
    lowData = tablex.retrieveDataAsCellArray(lowTbl, names, lowSpan, variant=":");
    highSpan = datex.upsample(lowSpan, highFreq);

    lowNumPeriods = numel(lowSpan);
    highNumPeriods = numel(highSpan);

    method = ensureStruct_(options.method, names);
    downscale = ensureStruct_(options.downscale, names);

    dispatch = struct( ...
        "last", @last_, ...
        "flat", @flat_, ...
        "nearest", @(varargin) interp1_("nearest", varargin{:}), ...
        "linear", @(varargin) interp1_("linear", varargin{:}), ...
        "next", @(varargin) interp1_("next", varargin{:}), ...
        "previous", @(varargin) interp1_("previous", varargin{:}), ...
        "pchip", @(varargin) interp1_("pchip", varargin{:}), ...
        "cubic", @(varargin) interp1_("cubic", varargin{:}) ...
    );

    commonArgs = {freqFactor, lowSpan, highSpan, lowHandler, highHandler};
    highData = cell(size(lowData));
    for i = 1 : numel(highData)
        name = names(i);
        lowVariable = lowData{i};
        %
        funcName = method.(name);
        func = dispatch.(funcName);
        shape = size(lowVariable);
        lowVariable = lowVariable(:, :);
        numColumns = size(lowVariable, 2);
        %
        highVariable = nan(highNumPeriods, numColumns);
        for j = 1 : numColumns
            highVariable(:, j) = func(lowVariable(:, j), commonArgs{:});
        end
        highVariable = reshape(highVariable, [highNumPeriods, shape(2:end)]);
        highData{i} = highVariable;
        %
        if downscale.(name)
            highData{i} = highData{i} / freqFactor;
        end
    end

    highTbl = tablex.fromCellArray(highData, names, highSpan);
    try
        higherDimNames = tablex.getHigherDims(lowTbl);
        highTbl = tablex.setHigherDims(highTbl, higherDimNames);
    end

end%


function x = ensureStruct_(x, names)
    if ~isstruct(x)
        value = x;
        x = struct();
        for n = names
            x.(n) = value;
        end
    end
end%


function highData = interp1_(method, lowData, freqFactor, lowSpan, highSpan, lowHandler, highHandler)
    lowDecimals = reshape(lowHandler.decimal(lowSpan), [], 1);
    highDecimals = reshape(highHandler.decimal(highSpan), [], 1);
    highData = interp1( ...
        lowDecimals, lowData, highDecimals, ...
        method, "extrap" ...
    );
end%


function highData = last_(lowData, freqFactor, lowSpan, highSpan, ~, ~)
    highData = nan(size(lowData, 1), freqFactor);
    highData(:, end) = lowData;
    highData = vect_(highData);
end%


function highData = flat_(lowData, freqFactor, lowSpan, highSpan, ~, ~)
    highData = repmat(lowData, 1, freqFactor);
    highData = vect_(highData);
end%


function x = vect_(x)
    x = x';
    x = x(:);
end%

