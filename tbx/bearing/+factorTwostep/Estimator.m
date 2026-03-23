
classdef (Abstract) Estimator ...
    < base.Estimator

    properties
        FAVAR
    end

    properties(Constant)
        CanHaveDummies = false
    end

    methods

        function initialize(this, meta, longYX, longZ)
            if this.BeenInitialized
                warning("This estimator has already been initialized; skipping initialization.");
                return
            end
            this.initializeFAVAR(meta, longYX, longZ);
            this.initializeSampler(meta, longYX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%

        function initializeFAVAR(this, meta, longYX, longZ)
            this.FAVAR = bear.initializeFAVARTwoStep( ...
                meta, ...
                longYX, ...
                longZ ...
            );
        end%
    end

end

