classdef favarIRFsettings < matlab.mixin.CustomDisplay
    % FAVARIRFSETTINGS (approximate) IRFs for information variables
 
    properties
        plot                  (1,1) logical = 0;
        % choose shock(s) to plot
        plotXshock = ''; %'FEVDshock';%'FYFF'; % FYFF 'USMP' % we need this atm only for IRFt2,3 provide =varendo for all shocks; in IRFt456 the identified shocks are plotted
        plotXblocks = 0;
    end
    
%     properties % Results
%         favar_irf_record cell = {};        
%         pltXshck (:,:) cell = {};
%         npltXshck
%         plotXshock_index
%         favar_irf_estimates
%         favar_irf_record_nottransformed
%         irf_record_nottransformed
%         favar_irf_record_allt
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