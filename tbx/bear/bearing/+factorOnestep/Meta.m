classdef Meta < factorTwostep.Meta

    properties (Constant, Access=private)
        % Fixed single reducible block name
        FIXED_BLOCK_NAME (1,1) string = "main"
        % Fixed block type
        FIXED_BLOCK_TYPE (1,1) string = "blocks"
    end

    methods
        function this = update(this, options)
            arguments
                this
                options.endogenousNames (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) {mustBeNonempty}

                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = false
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0

                options.reducibleNames (1, :) string = string.empty(1, 0)
                options.numFactors (1,1) double {mustBePositive, mustBeInteger} = 1
            end

            % Fixed values
            fixedBlockName = this.FIXED_BLOCK_NAME;
            fixedBlockType = this.FIXED_BLOCK_TYPE;

            % Convert scalar integer into struct required by superclass
            numFactorsStruct = struct(fixedBlockName, options.numFactors);

            this.ReducibleNames = options.reducibleNames;
            this.ReducibleBlocks = repmat(fixedBlockName, size(options.reducibleNames));
            this.BlockType = fixedBlockType;
            this.NumFactors = numFactorsStruct;

            options = rmfield(options, ["reducibleNames","numFactors"]);
            args = namedargs2cell(options);
            update@base.Meta(this, args{:});


        end
    end
end
