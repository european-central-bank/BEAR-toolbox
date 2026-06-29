
classdef BeenInitializedMixin ...
    < handle

    properties (SetAccess = protected)
        % BeenInitialized  True if the component has been initialized
        BeenInitialized (1, 1) logical = false
    end

    properties (Constant)
        MESSAGE = struct( ...
            "error", "The %s has already been initialized; aborting.", ...
            "skip", "The %s has already been initialized; skipping initialization.", ...
            "force", "The %s has already been initialized; reinitializing." ...
        )
    end

    methods
        function initialize(this, whenInitialized, componentName)
            arguments
                this
                whenInitialized (1, 1) string {mustBeMember(whenInitialized, ["error", "skip", "force"])}
                componentName (1, 1) string
            end
            %
            if this.BeenInitialized
                message = sprintf(this.MESSAGE.(whenInitialized), componentName);
                if whenInitialized == "error"
                    error(message);
                elseif whenInitialized == "skip"
                    warning(message);
                    return
                elseif options.WhenInitialized == "force"
                    warning(message);
                end
            end
            %
            this.BeenInitialized = true;
        end%
    end

end

