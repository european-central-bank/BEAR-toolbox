classdef favarFEVDsettings < matlab.mixin.CustomDisplay

    properties
        plot        (1,1) logical = 1;
        plotXblocks               = ''; % sum contributions of factors blockwise
    end

    methods (Access = protected)

        function propgrp = getPropertyGroups(obj)

            if obj.plot == 0
                proplist = {'plot'};
                propgrp = matlab.mixin.util.PropertyGroup(proplist);
            else
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);

            end

        end
        
    end

end