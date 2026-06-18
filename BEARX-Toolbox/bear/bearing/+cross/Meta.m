
classdef Meta ...
    < base.Meta

    properties (SetAccess=protected)
        Units (1, :) string = string.empty(1, 0)
    end


    methods
        function update(this, options)
            arguments
                this
                %
                options.endogenousConcepts (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) {mustBeNonempty}
                options.units (1, :) string {mustBeNonempty}
                %
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockConcepts (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
            end
            %
            this.EndogenousConcepts = options.endogenousConcepts;
            this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            this.Units = options.units;
            %
            this.ExogenousNames = options.exogenousNames;
            this.ShockConcepts = options.shockConcepts;
            this.HasIntercept = options.intercept;
            this.Order = options.order;
            this.IdentificationHorizon = options.identificationHorizon;
            %
            this.populatePseudoDependents();
            this.populateSeparablePseudoDependents();
            this.catchDuplicateNames();
        end%


        function populatePseudoDependents(this)
            this.NumUnits = numel(this.Units);
            %
            this.EndogenousNames = textual.crossList(this.SEPARATOR, this.Units, this.EndogenousConcepts);
            this.PseudoEndogenousNames = this.EndogenousNames;
            %
            this.ResidualConcepts = this.EndogenousConcepts + this.SEPARATOR + this.ResidualSuffix;
            this.ResidualNames = textual.crossList(this.SEPARATOR, this.Units, this.ResidualConcepts);
            %
            if isempty(this.ShockConcepts) || isequal(this.ShockConcepts, "") || all(ismissing(this.ShockConcepts))
                this.ShockConcepts = this.EndogenousConcepts + this.SEPARATOR + this.ShockSuffix;
            end
            this.ShockNames = textual.crossList(this.SEPARATOR, this.Units, this.ShockConcepts);
        end%


        function populateSeparablePseudoDependents(this)
            this.NumSeparableUnits = 1;
            this.SeparableEndogenousNames = this.EndogenousNames;
            this.SeparableResidualNames = this.ResidualNames;
            this.SeparableShockNames = this.ShockNames;
        end%
    end


    methods % Chart groups
        function out = getResponseChartGroups(this)
            out = cell.empty(1, 0);
            sep = this.SEPARATOR;
            for endogenousUnit = this.Units
                endogenousNames = endogenousUnit + sep + this.EndogenousConcepts;
                for shockUnit = this.Units
                    shockNames = shockUnit + sep + this.ShockConcepts;
                    out{end+1} = tablex.flattenNames(endogenousNames, shockNames); %#ok<AGROW>
                end
            end
        end%
    end

end

