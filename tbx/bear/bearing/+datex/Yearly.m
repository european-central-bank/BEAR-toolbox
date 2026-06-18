
classdef Yearly < datex.Regular

    properties (Constant)
        Frequency = datex.Frequency.YEARLY
        Format = "uuuu"
        %
        SdmxLen = 4
        SdmxPattern = digitsPattern(4)
        %
        LegacyLen = 5
        LegacyPattern = caseInsensitivePattern(digitsPattern(4) + "Y")
    end

    methods
        function dt = datetimeFromSdmx(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            dateString = extractBetween(dateString, 1, 4);
            dt = this.construct(double(dateString));
        end%

        function dt = datetimeFromLegacy(this, dateString)
            dt = this.datetimeFromSdmx(dateString);
        end%
    end

end

