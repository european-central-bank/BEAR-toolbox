
classdef Monthly < datex.Regular

    properties (Constant)
        Frequency = datex.Frequency.MONTHLY
        Format = "uuuu-MM"
        %
        SdmxLen = 7
        SdmxPattern = digitsPattern(4) + "-" + digitsPattern(2)
        %
        LegacyLen = 7
        LegacyPattern = caseInsensitivePattern(digitsPattern(4) + "M" + digitsPattern(2))
    end

    methods
        function dt = datetimeFromSdmx(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            dateString = extractBetween(dateString, 1, this.SdmxLen);
            splitDateString = split(dateString, "-");
            dt = this.construct(double(splitDateString(1)), double(splitDateString(2)));
        end%

        function dt = datetimeFromLegacy(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            dateString = extractBetween(dateString, 1, this.LegacyLen);
            splitDateString = split(upper(dateString), "M");
            dt = this.construct(double(splitDateString(1)), double(splitDateString(2)));
        end%
    end

end

