 
classdef Meta < matlab.mixin.Copyable

    % Reduced-form model meta information
    properties (SetAccess=protected)
        % Endogenous concepts; the entire names will be created
        % by prepending unit names to endogenous concepts
        EndogenousConcepts (1, :) string

        % Names of units in panel models
        % Units (1, :) string = string.empty(1, 0)

        % Names of exogenous variables
        ExogenousNames (1, :) string %Names of exogenous variables

        % Suffix appended to residual concepts
        ResidualSuffix (1, 1) string = "resid"

        % Suffix appended to shock concepts when generated automatically
        ShockSuffix (1, 1) string = "shock"

        % Autoregressive order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1

        % True if the model includes an intercept (constant) term
        HasIntercept (1, 1) logical

        % Span of fitted data
        ShortSpan
    end


    % Structural model meta information
    properties (SetAccess=protected)
        % Number of periods for which the VMA
        % representation (shock response matrices) will be drawn
        IdentificationHorizon (1, 1) double = NaN
    end


    properties (Constant)
        SEPARATOR = "_"
    end


    properties (SetAccess=protected) % Pseudo-dependents
        NumUnits
        NumSeparableUnits
        %
        EndogenousNames
        PseudoEndogenousNames
        SeparableEndogenousNames
        %
        ResidualConcepts
        ResidualNames
        SeparableResidualNames
        %
        % Names of structural shock concepts; the entire names
        % will be created by prepending unit names to shock concepts
        ShockConcepts (1, :) string = string.empty(1, 0)
        %
        % ShockNames  Names of structural shocks
        ShockNames
        %
        % SeparableShockNames  Names of separable structural shocks
        SeparableShockNames
    end


    properties (Dependent)
        HasExogenous
        NumExogenousNames
        %
        NumEndogenousConcepts
        NumEndogenousNames
        NumPseudoEndogenousNames
        NumSeparableEndogenousNames
        %
        NumResidualNames
        NumSeparableResidualNames
        NumResiduals
        %
        NumShockConcepts
        NumShockNames
        NumSeparableShockNames
    end


    properties (Dependent)
        ShortStart
        ShortEnd
        EstimationSpan
        EstimationStart
        EstimationEnd
        InitSpan
        InitStart
        InitEnd
        LongStart
        LongEnd
        LongSpan
        NumShortSpan
    end


    methods
        function this = Meta(varargin)
            if nargin == 0
                return
            end
            this.update(varargin{:});
        end%


        function update(this, options)
            arguments
                this
                %
                options.endogenousNames (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) {mustBeNonempty}
                %
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
            end
            %
            this.EndogenousConcepts = options.endogenousNames;
            this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            %
            this.ExogenousNames = options.exogenousNames;
            this.ShockConcepts = options.shockNames;
            this.HasIntercept = options.intercept;
            this.Order = options.order;
            this.IdentificationHorizon = options.identificationHorizon;
            %
            this.populatePseudoDependents();
            this.populateSeparablePseudoDependents();
            this.catchDuplicateNames();
            this.checkConsistency();
        end%


        function populatePseudoDependents(this)
            this.NumUnits = 1;
            %
            this.EndogenousNames = this.EndogenousConcepts;
            this.PseudoEndogenousNames = this.EndogenousNames;
            %
            this.ResidualConcepts = this.EndogenousConcepts + this.SEPARATOR + this.ResidualSuffix;
            this.ResidualNames = this.ResidualConcepts;
            %
            if isempty(this.ShockConcepts) || isequal(this.ShockConcepts, "") || all(ismissing(this.ShockConcepts))
                this.ShockConcepts = this.EndogenousConcepts + this.SEPARATOR + this.ShockSuffix;
            end
            this.ShockNames = this.ShockConcepts;
        end%


        function populateSeparablePseudoDependents(this)
            this.NumSeparableUnits = 1;
            this.SeparableEndogenousNames = this.EndogenousNames;
            this.SeparableResidualNames = this.ResidualNames;
            this.SeparableShockNames = this.ShockNames;
        end%


        function checkConsistency(this)
            if this.NumPseudoEndogenousNames ~= this.NumShockNames
                error("The number of shocks must equal the number of endogenous variables.");
            end
        end%


        function emptyYLX = createEmptyYLX(this)
            numY = this.NumEndogenousNames;
            numL = this.NumEndogenousNames * this.Order;
            numX = double(this.HasIntercept) + this.NumExogenousNames;
            emptyYLX = { ...
                zeros(0, numY), ...
                zeros(0, numL + numX), ...
            };
        end%
    end


    methods (Access=protected)
        function catchDuplicateNames(this)
            allNames = [ ...
                this.EndogenousNames, ...
                this.ExogenousNames, ...
                this.ShockNames ...
            ];
            if numel(allNames) ~= numel(unique(allNames))
                nonuniques = textual.nonunique(allNames);
                error("Duplicate model name(s): " + join(nonuniques, ", "));
            end
        end%
    end


    methods
        function out = getMeta(this)
            out = this;
        end%

        function start = get.ShortStart(this)
            start = this.ShortSpan(1);
        end%

        function out = get.ShortEnd(this)
            out = this.ShortSpan(end);
        end%

        function out = get.EstimationSpan(this)
            out = this.ShortSpan;
        end%

        function out = get.EstimationStart(this)
            out = this.ShortSpan(1);
        end%

        function out = get.EstimationEnd(this)
            out = this.ShortSpan(end);
        end%

        function out = get.InitSpan(this)
            out = datex.span(this.InitStart, this.InitEnd);
        end%

        function out = get.InitStart(this)
            out = datex.shift(this.ShortSpan(1), -this.Order);
        end%

        function out = get.InitEnd(this)
            out = datex.shift(this.ShortSpan(1), -1);
        end%

        function out = get.LongStart(this)
            out = datex.shift(this.ShortStart, -this.Order);
        end%

        function out = get.LongEnd(this)
            out = this.ShortEnd;
        end%

        function out = get.LongSpan(this)
            out = datex.span(this.LongStart, this.LongEnd);
        end%

        function out = get.NumShortSpan(this)
            out = numel(this.ShortSpan);
        end%

        function out = get.HasExogenous(this)
            out = ~isempty(this.ExogenousNames);
        end%
    end


    methods
        function out = get.NumExogenousNames(this)
            out = numel(this.ExogenousNames);
        end%

        function out = get.NumEndogenousConcepts(this)
            out = numel(this.EndogenousConcepts);
        end%

        function out = get.NumEndogenousNames(this)
            out = numel(this.EndogenousNames);
        end%

        function out = get.NumPseudoEndogenousNames(this)
            out = numel(this.PseudoEndogenousNames);
        end%

        function out = get.NumSeparableEndogenousNames(this)
            out = numel(this.SeparableEndogenousNames);
        end%

        function out = get.NumResidualNames(this)
            out = numel(this.ResidualNames);
        end%

        function out = get.NumSeparableResidualNames(this)
            out = numel(this.SeparableResidualNames);
        end%

        function out = get.NumResiduals(this)
            out = this.NumResidualNames;
        end%

        function out = get.NumShockConcepts(this)
            out = numel(this.ShockConcepts);
        end%

        function out = get.NumShockNames(this)
            out = numel(this.ShockNames);
        end%

        function out = get.NumSeparableShockNames(this)
            out = numel(this.SeparableShockNames);
        end%
    end


    methods % Chart groups
        function out = getForecastChartGroups(this)
            out = { ...
                this.PseudoEndogenousNames, ...
                this.ResidualNames, ...
                this.ExogenousNames, ...
            };
        end%

        function out = getConditionalForecastChartGroups(this)
            out = { ...
                this.PseudoEndogenousNames, ...
                this.ShockNames, ...
                this.ExogenousNames, ...
            };
        end%

        function out = getResponseChartGroups(this)
            out = { ...
                tablex.flattenNames(this.PseudoEndogenousNames, this.ShockNames), ...
            };
        end%

        function out = getContributionsChartGroups(this)
            out = { ...
                this.PseudoEndogenousNames, ...
            };
        end%
    end

end

