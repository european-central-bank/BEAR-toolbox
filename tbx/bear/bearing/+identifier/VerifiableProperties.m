
classdef VerifiableProperties < handle

    properties
        Model
        LongYXZ (1, :) cell
        Indexes identifier.Indexes

        HistoryDraw
        IdentificationDraw
    end


    properties (Dependent)
        Meta
        HistoryDrawer
        IdentificationDrawer
    end


    properties (Transient)
        Sample
        ValueSHKRESP
        ValueSHKEST
        ValueSHKCONT
    end


    methods
        function this = VerifiableProperties(modelS)
            this.Model = modelS;
            this.LongYXZ = this.Model.getLongYXZ();
            this.Indexes = identifier.Indexes(this.Meta);
        end%

        function initialize4S(this, sample)
            arguments
                this
                sample (1, 1) struct
            end
            this.clearTransients();
            this.Sample = sample;
        end%

        function clearTransients(this)
            % clear  Clear transient properties
            mc = metaclass(this);
            for prop = reshape(mc.PropertyList, 1, [])
                if prop.Transient
                    this.(prop.Name) = [];
                end
            end
        end%

        function out = getIdentificationDraw(this)
            if isempty(this.IdentificationDraw)
                this.IdentificationDraw = this.IdentificationDrawer(this.Sample);
            end
            out = this.IdentificationDraw;
        end%

        function out = getHistoryDraw(this)
            if isempty(this.HistoryDraw)
                this.HistoryDraw = this.HistoryDrawer(this.Sample);
            end
            out = this.HistoryDraw;
        end%
    end


    methods
        function value = extractSHKRESP(this, period, endogenousName, shockName)
            %[
            arguments
                this
                period (1, 1) double
                endogenousName (1, 1) string
                shockName (1, 1) string
            end
            if isempty(this.ValueSHKRESP)
                % Array Y4S is numT x numY x numP x numUnits
                [Y4S, this.Sample] = this.Model.simulateResponses4S(this.Sample);
                this.ValueSHKRESP = Y4S;
            end
            value = this.ValueSHKRESP( ...
                period, ...
                this.Indexes.SeparableEndogenousNames.(endogenousName), ...
                this.Indexes.SeparableShockNames.(shockName) ...
            );
            %]
        end%

        function value = extractSHKEST(this, period, shockName)
            %[
            arguments
                this
                period (1, 1) string
                shockName (1, 1) string
            end
            if isempty(this.ValueSHKEST)
                this.ValueSHKEST = this.Model.estimateShocks4S(this.Sample, this.LongYXZ);
            end
            period = datex.toFieldable(period);
            value = this.ValueSHKEST( ...
                this.Indexes.HistoryPeriods.(period), ...
                this.Indexes.ShockNames.(shockName) ...
            );
            %]
        end%

        function value = extractSHKCONT(this, period, endogenousName, shockName)
            %[
            arguments
                this
                period (1, 1) string
                endogenousName (1, 1) string
                shockName (1, 1) string
            end
            if isempty(this.ValueSHKCONT)
                if isempty(this.ValueSHKEST)
                    this.ValueSHKEST = this.Model.estimateShocks4S(this.Sample, this.LongYXZ);
                end
                this.ValueSHKCONT = this.Model.computeShockContributions4S(this.Sample, this.ValueSHKEST);
            end
            period = datex.toFieldable(period);
            value = this.ValueSHKCONT( ...
                this.Indexes.HistoryPeriods.(period), ...
                this.Indexes.EndogenousNames.(endogenousName), ...
                this.Indexes.ShockNames.(shockName) ...
            );
            %]
        end%
    end


    methods
        function out = get.Meta(this)
            out = this.Model.Meta;
        end%

        function out = get.HistoryDrawer(this)
            out = this.Model.HistoryDrawer;
        end%

        function out = get.IdentificationDrawer(this)
            out = this.Model.IdentificationDrawer;
        end%
    end

end

