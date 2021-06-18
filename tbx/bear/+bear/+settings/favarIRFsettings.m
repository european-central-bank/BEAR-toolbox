classdef favarIRFsettings < matlab.mixin.CustomDisplay
    % FAVARIRFSETTINGS (approximate) IRFs for information variables
 
    properties
        plot                  (1,1) logical = 0;
        % choose shock(s) to plot
        plotXshock = ''; %'FEVDshock';%'FYFF'; % FYFF 'USMP' % we need this atm only for IRFt2,3 provide =varendo for all shocks; in IRFt456 the identified shocks are plotted
        plotXblocks = 0;
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