
classdef Engine

    enumeration
        LOG (@log, 0, "EXP")
        EXP (@exp, 0, "LOG")
        DIFF (@(x) diff(x, 1, 1), -1, "CUM")
        DIFF2 (@(x) diff(x, 2, 1), -2, "CUM2")
        DIFFLOG (@(x) diff(log(x), 1, 1), -1, "CUMLOG")
        DIFF2LOG (@(x) diff(log(x), 2, 1), -2, "CUM2LOG")
        CUM (@(x) cumsum(x, 1), 1, "DIFF")
    end


    properties
        Function
        NumInit (1, 1) double
        Inverse (1, 1) string
    end


    properties (Dependent)
        InverseEngine
    end


    methods
        function this = Engine(func, numInit, inverse)
            arguments
                func
                numInit (1, 1) double
                inverse (1, 1) string
            end
            this.Function = func;
            this.NumInit = numInit;
            this.Inverse = upper(inverse);
        end%

        function data = applyToVector(this, data, init)
            arguments
                this
                data double
                init double = []
            end
            data = this.preprocess(data, init);
            data = this.Function(data);
            data = this.postprocess(data);
        end%

        function data = applyInverseToVector(this, data, init)
            arguments
                this
                data double
                init double = []
                keepNumPeriods (1, 1) logical = true
            end
            inverse = this.InverseEngine;
            data = inverse.preprocess(data, init);
            data = inverse.Function(data);
            if keepNumPeriods
                data = inverse.keepNumPeriods(data);
            end
        end%

        function data = preprocess(this, data, init)
            arguments
                this
                data
                init double = []
            end
            init = transformer.ensureDim(init, this.NumInit, data);
            data = [init; data];
        end%

        function data = keepNumPeriods(this, data)
            if this.NumInit == 0
                return
            end
            if this.NumInit > 0
                higherDim = repmat({':'}, 1, ndims(data)-1);
                data = data(this.NumInit:end, higherDim{:});
                return
            end
            if this.NumInit < 0
                sizeData = size(data);
                add = nan([-this.NumInit, sizeData(2:end)]);
                data = [add; data];
                return
            end
        end%
    end


    methods
        function inverse = get.InverseEngine(this)
            inverse = transformer.Engine(this.Inverse);
        end%
    end
end

