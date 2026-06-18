
classdef Meta ...
    < cross.Meta

    methods
        function populateSeparablePseudoDependents(this)
            this.NumSeparableUnits = this.NumUnits;
            this.SeparableEndogenousNames = this.EndogenousConcepts;
            this.SeparableResidualNames = this.ResidualConcepts;
            this.SeparableShockNames = this.ShockConcepts;
        end%
    end


    methods % Chart groups
        function out = getResponseChartGroups(this)
            out = cell.empty(1, 0);
            sep = this.SEPARATOR;
            for unit = this.Units
                endogenousNames = unit + sep + this.EndogenousConcepts;
                out{end+1} = tablex.flattenNames(endogenousNames, this.ShockConcepts); %#ok<AGROW>
            end
        end%
    end

end

