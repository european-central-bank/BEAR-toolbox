
classdef Logger < int16

    enumeration
        ALL (0)
        DEBUG (1)
        INFO (2)
        WARNING (3)
        ERROR (4)
        CRITICAL (5)
        OFF (6)
    end

    methods
        function debug(this, varargin)
            this.print(bear6.Logger.DEBUG, varargin{:});
        end%

        function info(this, varargin)
            this.print(bear6.Logger.INFO, varargin{:});
        end%

        function warning(this, varargin)
            this.print(bear6.Logger.WARNING, varargin{:});
        end%

        function error(this, varargin)
            this.print(bear6.Logger.ERROR, varargin{:});
        end%

        function critical(this, varargin)
            this.print(bear6.Logger.CRITICAL, varargin{:});
        end%

        function print(this, level, varargin)
            if level >= this
                if numel(varargin) == 1
                    message = varargin{1};
                else
                    message = sprintf(varargin{:});
                end
                fprintf("[%s][%s] %s\n", this, datestr(now), message);
            end
        end%
    end

end

