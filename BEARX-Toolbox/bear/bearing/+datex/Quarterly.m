
classdef Quarterly < datex.Regular

    properties (Constant)
        Frequency = datex.Frequency.QUARTERLY
        Format = "uuuu-'Q'Q"
        %
        SdmxLen = 7
        SdmxPattern = caseInsensitivePattern(digitsPattern(4) + "-Q" + digitsPattern(1))
        %
        LegacyLen = 6
        LegacyPattern = caseInsensitivePattern(digitsPattern(4) + "Q" + digitsPattern(1))
    end

    methods
        function dt = datetimeFromSdmx(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            dateString = extractBetween(dateString, 1, this.SdmxLen);
            splitDateString = split(upper(dateString), "-Q");
            dt = this.construct(double(splitDateString(1)), double(splitDateString(2)));
        end%

        function dt = datetimeFromLegacy(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            dateString = extractBetween(dateString, 1, this.LegacyLen);
            splitDateString = split(upper(dateString), "Q");
            dt = this.construct(double(splitDateString(1)), double(splitDateString(2)));
        end%
    end

end

