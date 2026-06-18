
classdef (CaseInsensitiveProperties=true) MixedFrequency

    properties
        MixedLambda1 (1, 1) double = 1.e-01;

        MixedLambda2 (1, 1) double = 3.4;

        MixedLambda3 (1, 1) double = 1;

        MixedLambda4 (1, 1) double = 3.4;

        MixedLambda5 (1, 1) double = 1.4763158e+01;
    end

    methods
        function this = update(this, meta, varargin)
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%
    end

end

