
classdef Regular < datex.FrequencyHandler

    methods
        function dt = construct(this, varargin)
            if numel(varargin) == 1 && isa(varargin{1}, 'datetime')
                func = @this.datetimeFromDatetime;
            else
                func = @this.datetimeFromYepe;
            end
            dt = func(varargin{:});
        end%

        function dt = datetimeFromDatetime(this, dt)
            serial = serialFromDatetime(this, dt);
            dt = datetimeFromSerial(this, serial);
        end%

        function dt = datetimeFromYepe(this, year, per)
            arguments
                this
                year (1, :) double
                per (1, :) double = 1
            end
            %
            serial = this.serialFromYepe(year, per);
            dt = [];
            for i = reshape(serial, 1, [])
                dt = [dt, this.datetimeFromSerial(i)]; %#ok<AGROW>
            end
        end%

        function dt = datetimeFromSerial(this, serial)
            [year, month, day] = yemodaFromSerial(this, serial);
            dt = datetime(year, month, day);
            dt.Format = this.Format;
        end%

        function serial = serialFromDatetime(this, dt)
            per = perFromMonth(this, dt.Month);
            serial = serialFromYepe(this, dt.Year, per);
        end%

        function serial = serialFromYepe(this, year, per)
            serial = round(year * this.Frequency + per - 1);
        end%

        function [year, per] = yepeFromDatetime(this, dt)
            year = dt.Year;
            per = this.perFromMonth(dt.Month);
        end%

        function [year, per] = yepeFromSerial(this, serial)
            year = floor(serial / this.Frequency);
            per = round(serial - year * this.Frequency + 1);
        end%

        function [year, month, day] = yemodaFromSerial(this, serial)
            [year, per] = yepeFromSerial(this, serial);
            month = monthFromPer(this, per);
            day = 1;
        end%

        function per = perFromMonth(this, month)
            per = ceil(month / (12 / this.Frequency));
        end%

        function month = monthFromPer(this, per, position)
            month = round((per - 1) * (12 / this.Frequency) + 1);
        end%

        function decimal = decimalFromYepe(this, year, per)
            offset = 1 ./ (2 * this.Frequency);
            decimal = year + (per - 1) ./ this.Frequency + offset;
        end%

        function decimal = decimal(this, dt)
            [year, per] = this.yepeFromDatetime(dt);
            decimal = this.decimalFromYepe(year, per);
        end%
    end

end

