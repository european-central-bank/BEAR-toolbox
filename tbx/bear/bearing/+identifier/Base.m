
% identifier.Base  Abstract Identifier class for identification schemes

classdef (Abstract) Base ...
    < matlab.mixin.Copyable

    properties
        % Sampler  Handle to the reduced-form sample generating function
        Sampler

        % CandidateCounter  Total number of candidates generated so far
        CandidateCounter (1, 1) uint64 = 0
    end


    properties (SetAccess=protected)
        % SamplerCounter  Total number of samples generated so far
        SampleCounter (1,1) uint64 = 0

        % Candidator  Handle to the candidate generating function
        Candidator

        % SeparableEndogenousNames  Endogenous names or endogenous concepts
        SeparableEndogenousNames (1, :) string

        % SeparableShockNames  Shock names or shock concepts
        SeparableShockNames (1, :) string

        % BeenInitialized  True if the identifier has been initialized
        BeenInitialized (1, 1) logical = false
    end


    properties (Dependent)
        ShortClassName
    end


    methods (Abstract)
        varargout = whenPairedWithModel(this, varargin)
        varargout = initializeSampler(this, varargin)
    end


    methods
        function varargout = initialize(this, modelS)
            if this.BeenInitialized
                warning("The identifier has already been initialized.");
                return
            end
            %
            meta = modelS.getMeta();
            this.beforeInitializeSampler(modelS);
            this.initializeSampler(modelS);
            this.afterInitializeSampler(modelS);
        end%

        function deinitialize(this)
            this.BeenInitialized = false;
            this.SampleCounter = uint64(0);
            this.CandidateCounter = uint64(0);
            this.Sampler = [];
            this.Candidator = [];
        end%

        function populateSeparableNames(this, meta)
            this.SeparableEndogenousNames = meta.SeparableEndogenousNames;
            this.SeparableShockNames = meta.SeparableShockNames;
        end%

        function beforeInitializeSampler(this, modelS)
        end%

        function afterInitializeSampler(this, modelS)
        end%
    end


    methods
        function out = get.ShortClassName(this)
            out = extractAfter(class(this), "identifier.");
        end%
    end

end

