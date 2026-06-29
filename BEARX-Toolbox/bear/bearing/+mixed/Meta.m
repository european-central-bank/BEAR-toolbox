
classdef Meta ...
    < base.Meta

    properties (SetAccess=protected)
        NumHighFrequencyNames (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
        NumLowFrequencyNames (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
    end


    methods
        function update(this, options)
            arguments
                this
                %
                options.highFrequencyNames (1, :) string {mustBeNonempty}
                options.lowFrequencyNames (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) {mustBeNonempty}
                %
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
            end
            %
            this.NumHighFrequencyNames = numel(options.highFrequencyNames);
            this.NumLowFrequencyNames = numel(options.lowFrequencyNames);
            options.endogenousNames = [options.highFrequencyNames, options.lowFrequencyNames];
            %
            options = rmfield(options, ["highFrequencyNames", "lowFrequencyNames"]);
            args = namedargs2cell(options);
            update@base.Meta(this, args{:});
        end%
    end

end

