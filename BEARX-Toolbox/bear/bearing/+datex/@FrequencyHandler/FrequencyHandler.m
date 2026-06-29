
classdef (Abstract) FrequencyHandler

    properties (Abstract, Constant)
        SdmxPattern
        SdmxLen
        LegacyPattern
        LegacyLen
    end

    methods (Abstract)
        dt = datetimeFromSdmx(varargin)
    end

    methods
        function tf = matchDatetime(this, dt)
            tf = isequal(this.Format, dt.Format);
        end%

        function flag = validateSdmx(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            flag = ...
                strlength(dateString) == this.SdmxLen ...
                && ~isempty(extract(dateString, this.SdmxPattern));
        end%

        function flag = validateLegacy(this, dateString)
            arguments
                this
                dateString (1, 1) string
            end
            flag = ...
                strlength(dateString) == this.LegacyLen ...
                && ~isempty(extract(dateString, this.LegacyPattern));
        end%
    end

end

