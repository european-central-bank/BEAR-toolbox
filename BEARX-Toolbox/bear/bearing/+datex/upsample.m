
function highDates = upsample(lowDates, highFreq)

    arguments
        lowDates (1, :) datetime
        highFreq (1, 1) double {mustBeMember(highFreq, [1, 4, 12])}
    end

    if isempty(lowDates)
        highDates = datetime.empty(1, 0);
        return
    end

    lowFreq = datex.frequency(lowDates(1));

    if lowFreq == highFreq
        highDates = lowDates;
        return
    end

    if lowFreq > highFreq
        error("Cannot upsample from frequency %d to frequency %d.", lowFreq, highFreq);
    end

    freqMultiplier = highFreq / lowFreq;
    if freqMultiplier ~= round(freqMultiplier)
        error("Cannot upsample from frequency %d to frequency %d.", lowFreq, highFreq);
    end

    lowHandler = datex.getFrequencyHandler(lowFreq);
    highHandler = datex.getFrequencyHandler(highFreq);
    highDates = [];

    [lowYears, lowPeriods] = lowHandler.yepeFromDatetime(lowDates);
    highYears = repmat(lowYears, freqMultiplier, 1);
    highYears = transpose(highYears(:));
    highPeriods = freqMultiplier * (lowPeriods - 1) + transpose(1 : freqMultiplier);
    highPeriods = transpose(highPeriods(:));

    highDates = highHandler.datetimeFromYepe(highYears, highPeriods);

end%

