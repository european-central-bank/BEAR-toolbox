
classdef (Abstract, CaseInsensitiveProperties=true) Settings

    properties
        % Number of burn-in draws
        % Bu
        Burnin (1, 1) double = 0 %Bu in BEAR5

        % Threshold for maximum eigenvalue magnitude
        StabilityThreshold (1, 1) double = Inf

        % Maximum number of unstable sampling attempts
        MaxNumUnstableAttempts (1, 1) double = 1000
    end


    properties
        % Priors on exogenous variables flag
        % priorexogenous
        Exogenous (:, :) logical = false %% priorexogenous in BEAR5, controls whether to use priors on exogenous

        % Block exogeneity flag
        % bex
        BlockExogenous (1, 1) logical = false %bex in BEAR5, controls whether to use block exogenity

        % Prior on first-order autoregression
        % ar
        Autoregression (:, 1) double = 0.8 %ar in BEAR5, the prior mean of the first lag

        % Overall tightness of priors
        % lambda1
        Lambda1 double = 0.1 %lambda1 in BEAR5 , contols the overal tightness of priors

        % Variable weighting
        % lambda2
        Lambda2 double = 0.5 %lambda2 in BEAR5, controls cross variable weightning

        % Leg decay
        % lambda3
        Lambda3 double = 1 %lambda 3 in BEAR5, controls leg decay

        % Exogenous variable tightness
        % lambda4
        Lambda4 (:, :) double = 100 %lambda4 in BEAR5, controls exogenous variable tightness

        % Block exogeneity shrinkage
        % lambda5
        Lambda5 double = 0.001 %lambda5 block exogeneity shrinkage hyperparameter
    end


    methods
        function this = update(this, meta, varargin)
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
            %
            numY = meta.NumEndogenousNames;
            numX = meta.NumExogenousNames;
            numXI = numX + double(meta.HasIntercept);
            %
            if isscalar(this.Exogenous)
                this.Exogenous = repmat(this.Exogenous, numY, numXI);
            end
            %
            if isscalar(this.Lambda4)
                this.Lambda4 = repmat(this.Lambda4, numY, numXI);
            end
            %
            if isscalar(this.Autoregression)
                this.Autoregression = repmat(this.Autoregression, numY, 1);
            end
            %
            if ~isfinite(this.StabilityThreshold) || this.StabilityThreshold <= 0
                this.StabilityThreshold = Inf;
            end
        end%
    end

end

