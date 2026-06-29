
classdef (Abstract) AbstractFixed < item.Abstract

    properties (Dependent)
        DisplayName
    end

    methods
        function name = get.DisplayName(this)
            splitClass = split(class(this), ".");
            name = this.PREFIX + string(splitClass(end));
        end%
    end

end

