
classdef (CaseInsensitiveProperties=true) Base ...
    < matlab.mixin.Copyable

    methods (Abstract)
        varargout = generate(this, varargin)
    end

end

