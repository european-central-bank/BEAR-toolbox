
classdef ReducedForm < base.ReducedForm

    methods
        function this = ReducedForm(varargin)
            this@base.ReducedForm(varargin{:});
        end%

        function someYX = getSomeYX(this, span)
            meta = this.Meta;
            someYX = this.DataHolder.getYX(span=span);
            someYX{1} = reshape(someYX{1}, size(someYX{1}, 1), [], meta.NumSeparableUnits);
        end%
    end

end

