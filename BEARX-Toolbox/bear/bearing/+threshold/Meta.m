
classdef Meta ...
    < base.Meta

    properties (SetAccess=protected)
        % ThresholdName  Name of the variable identifying the regime
        ThresholdName (1, 1) string = ""

        % ThresholdNameIndex  Index of the threshold variable withing endogenous variables
        ThresholdNameIndex (1, 1) double {mustBeInteger, mustBePositive} = 1
    end


    methods

        function this = update(this, options)
            arguments
                this
                %
                options.endogenousNames (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) {mustBeNonempty}
                options.thresholdName (1, 1) string
                %
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
                %
            end
            this.ThresholdName = options.thresholdName;
            %
            options = rmfield(options, ["thresholdName"]);
            args = namedargs2cell(options);
            update@base.Meta(this, args{:});
            %
            this.ThresholdNameIndex = find(this.EndogenousNames == this.ThresholdName, 1);
            if isempty(this.ThresholdNameIndex)
                error("The specified threshold variable name '%s' is not found among the endogenous variable names.", this.ThresholdName);
            end
        end%

    end

end

