classdef favarFEVDsettings < matlab.mixin.CustomDisplay

    properties
        plot        (1,1) logical = 0; % (1=yes, 0=no)
        % choose shock(s) to plot
        plotXshock char = '';
        plotXblocks char = ''; %'EA.factor1 EA.factor2 EA.factor3 EA.factor4 EA.factor5 EA.factor6';
        
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
    
    methods (Hidden)
        function propgrp = getActiveProperties(obj)
            propgrp = getPropertyGroups(obj);
            propgrp = propgrp.PropertyList;
            if isstruct(propgrp)
                propgrp = fields(propgrp);
            end
        end
    end

end