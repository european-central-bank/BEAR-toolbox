
classdef (Abstract) Abstract

    properties (Constant, Hidden)
        PREFIX = "@"
    end

    properties (Abstract, SetAccess = protected)
        NumColumns (1, 1) double
    end

    properties (Abstract, Dependent)
        DisplayName
    end

    methods (Abstract)
        dataColumns = getData(this, dataTable, periods)
    end

    methods
        function s = string(this)
            s = this.DisplayName;
        end%
    end

end

