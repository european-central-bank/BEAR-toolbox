
classdef Meta ...
    < base.Meta

    % Reduced-form model meta information
    properties (SetAccess=protected)
        %Trend type of variables in mean-adjusted models
        TrendType(1, :) string

        % Number of regimes of the given variable
        NumRegimes (1, :) double

        % Bounds of constants
        Bounds cell

        % Regime spans
        Regimes cell
    end


    properties (Dependent)
        NumTrendParams
        CMask
    end


    methods

        function this = update(this, options)
            arguments
                this
                options.endogenousNames (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) datetime {mustBeNonempty}

                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0

                options.trendType (1,:) string {mustBeMember(options.trendType, ["constant", "time", "quadratic"])} = "constant"
                options.regimeSpans cell
                options.numRegimes (1, :) double {mustBeNonempty}
                options.bounds cell
            end

            this.HasIntercept = false;
            this.ExogenousNames = string.empty(1, 0);

            this.EndogenousConcepts = options.endogenousNames;
            this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            %
            this.ShockConcepts = options.shockNames;
            this.Order = options.order;
            this.IdentificationHorizon = options.identificationHorizon;

            this.TrendType = options.trendType;
            this.NumRegimes = options.numRegimes;
            this.Bounds = options.bounds;

            this.extendRegime(options.regimeSpans);

            this.populatePseudoDependents();
            this.populateSeparablePseudoDependents();
            this.catchDuplicateNames();


        end%


        function extendRegime(this, regimeSpans)
            this.Regimes = regimeSpans;
            nRegs = size(regimeSpans, 2);
            freq = datex.frequency(this.EstimationSpan);

            switch freq
                case 12
                    latestEnd = datex.m(1800,1);
                    earliestStart = datex.m(18000,1);
                case 4
                    latestEnd = datex.q(1800,1);
                    earliestStart = datex.q(18000,1);
                case 1
                    latestEnd = datex.y(1800,1);
                    earliestStart = datex.y(18000,1);
            end

            for r = 1:nRegs
                spans = regimeSpans{r}{1};
                % Track latest end date
                thisMax = max(spans(end));
                if thisMax > latestEnd
                    latestEnd = thisMax;
                    latestRegimeIdx = r;
                end
                thisMin = min(spans(1));
                if thisMin < earliestStart
                    earliestStart = thisMin;
                    earliestRegimeIdx = r;
                end
            end

            extStart = datex.shift(latestEnd, 1);
            extEnd = datex.shift(latestEnd, 100*freq);
            this.Regimes{latestRegimeIdx}{1} = [
                this.Regimes{latestRegimeIdx}{1}, ...
                datex.span(extStart, extEnd), ...
            ];

            prepEnd = datex.shift(earliestStart, -1);
            prepStart = datex.shift(earliestStart, -100*freq);
            this.Regimes{earliestRegimeIdx}{1} = [ ...
                datex.span(prepStart, prepEnd), ...
                this.Regimes{earliestRegimeIdx}{1}, ...
            ];
        end%


        function X = getX(this, someSpan)
            numRegimes = this.NumRegimes;
            regimes = this.Regimes;
            trendCount = this.NumTrendParams;
            nVars = this.NumEndogenousNames;
            order = this.Order;

            T = numel(someSpan);

            X = zeros(T, sum(trendCount));

            startDay = this.EstimationStart;
            fh = datex.Backend.getFrequencyHandlerFromDatetime(startDay);
            timeVals = fh.serialFromDatetime(someSpan) -  fh.serialFromDatetime(startDay) + 1 + order;
            timeVals = timeVals(:);  % column vector

            for t = 1:T
                currentDate = someSpan(t);
                timeVal = timeVals(t);

                for v = 1:nVars
                    nRegs = numRegimes(v);
                    nTrends = trendCount(v)/nRegs;

                    if v == 1
                        baseCol = 1;
                    else
                        baseCol = sum(trendCount(1:v-1)) + 1;
                    end

                    if nRegs == 1
                        reg = 1;  % no regime split for this variable
                    else
                        for r = 1:nRegs

                            if any(regimes{r}{1} == currentDate)

                                reg = r;
                                break;
                            end
                        end
                    end

                    for tr = 1:nTrends
                        col = baseCol + (reg - 1) * nTrends + (tr - 1);
                        switch tr
                            case 1, X(t,col) = 1;
                            case 2, X(t,col) = timeVal;
                            case 3, X(t,col) = timeVal^2;
                        end
                    end
                end
            end
        end%

    end


    methods

        function num = get.NumTrendParams(this)
            trendType = this.TrendType;
            numRegimes = this.NumRegimes;

            % Map trend type to number of trend components
            trendMap = struct("constant", 1, "time", 2, "quadratic", 3);
            nVars = this.NumEndogenousNames;

            % First pass: calculate total number of parameters
            num = nan(1, nVars);

            for i = 1:nVars
                num(i) = trendMap.(trendType(i)) * numRegimes(i);
            end
        end%


        function mask  = get.CMask(this)
            numRegimes = this.NumRegimes;
            trendCount = this.NumTrendParams;
            nVars = this.NumEndogenousNames;

            % First pass: calculate total number of parameters
            totalParams = sum(trendCount);

            % Create full CMask (2D)
            mask = false(totalParams, nVars);

            row = 1;

            for v = 1:nVars
                nTrends = trendCount(v)/numRegimes(v);
                for r = 1:numRegimes(v)
                    for t = 1:nTrends
                        mask(row, v) = true;
                        row = row + 1;
                    end
                end
            end
        end%

    end

end

