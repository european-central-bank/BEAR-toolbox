
classdef ReducedForm ...
    < base.ReducedForm

    methods

        function initialize(this)
            longYX = this.getLongYX();
            longZ = this.getLongZ();
            this.Estimator.initialize(this.Meta, longYX, longZ);
        end%

        function longZ = getLongZ(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            longSpan = datex.longSpanFromShortSpan(shortSpan, this.Meta.Order);
            longZ = this.DataHolder.getZ(span=longSpan);
        end%

    end


    methods (Access = protected)

        function initY = getInitY(this, ~, order, sample, startindex)
            initY = sample.FY(startindex:order+startindex-1,:);
        end%

        function longY = getLongY4Resid(this, ~, sample)
            longY = sample.FY;
        end%

        function forecastNames = getForecastNames(this)
            meta = this.Meta;
            forecastNames = [ ...
                meta.FactorNames, ...
                meta.EndogenousNames, ...
                meta.getResidualNames, ...
                meta.ExogenousNames ...
            ];
        end%

    end

end

