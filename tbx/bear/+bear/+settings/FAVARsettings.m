classdef FAVARsettings < matlab.mixin.CustomDisplay
    % FAVAR options

    properties
        FAVAR (1,1) logical = 0

        transformation (1,1) logical = 1; % 'factor data' must contain values for startdate -1 in the case we have First Difference (2,5) transformation types and startdate -2 in the case we have Second Difference (3,6) transformation types
        transform_endo='6 2'; %'2 6' transformation codes of varendo variables other than factors

        % standardises (information) data in excel sheets 'data' and 'factor data'
        standardise (1,1) logical = 1; % (1=yes (default), 0=no)
        % demeans (information) data in excel sheets 'data' and 'factor data'
        demean (1,1) logical = 1; % (1=yes, 0=no)

        %     % specify the ordering of endogenpous factors and variables
        %     varendo = 'factor1 factor2 factor3 factor4 PUNEW FYFF';

        blocks (1,1) logical = 0;  % blocks/categories (1=yes, 0=no), specify in excel sheet
        numpc = 4;                 % choose number of factors (principal components) to include
        blocknames = 'slow fast';  % specify in excel sheet 'factor data'
        blocknumpc = '2 2';        % block-specific number of factors (principal components)

        % specify information variables of interest (plot and excel output) (HD & IRFs)
        plotX = 'IPS10 PMCP LHEM LHUR'

        HD   (1,1) bear.settings.favarHDsettings   = bear.settings.favarHDsettings
        IRF  (1,1) bear.settings.favarIRFsettings  = bear.settings.favarIRFsettings
        FEVD (1,1) bear.settings.favarFEVDsettings = bear.settings.favarFEVDsettings
    end

    methods 
        function obj = FAVARsettings(varargin)
            
            obj = bear.utils.pvset(obj, varargin{:});

        end
    end

    methods (Access = protected)

        function propgrp = getPropertyGroups(obj)

            if obj.FAVAR == 0
                proplist = {'FAVAR'};
                propgrp = matlab.mixin.util.PropertyGroup(proplist);
            else
                if obj.blocks == 0
                    proplist = properties(obj);
                    proplist = proplist(~ismember(proplist, {'blocknames','blocknumpc'}));
                    propgrp = matlab.mixin.util.PropertyGroup(proplist);
                else
                    proplist = properties(obj);
                    proplist = proplist(~ismember(proplist, {'numpc'}));
                    propgrp = matlab.mixin.util.PropertyGroup(proplist);
                end

            end

        end

    end

end