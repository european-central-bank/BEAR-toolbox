classdef favarHDsettings < matlab.mixin.CustomDisplay

    properties
        plot                  (1,1) logical = 0;
        sumShockcontributions (1,1) logical = 1; % sum contributions over shocks (=1), or over variables (=0, standard), only for IRFt2,3\\this option makes no sense in IRFt4,6
        plotXblocks                         = 1; % sum contributions of factors blockwise
        HDallsumblock         (1,1) logical = 0; % include all components of HDall(=1) other than shock contributions, but display them sumed under blocks\shocks
    end
    
%     properties % Results
%        hd_estimates 
%        favar_hd_record
%     end

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