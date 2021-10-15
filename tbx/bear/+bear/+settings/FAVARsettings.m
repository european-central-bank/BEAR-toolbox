classdef FAVARsettings < matlab.mixin.CustomDisplay
    % FAVARSETTINGS Favar options
    
    properties
        FAVAR (1,1) logical = 0
        
        transformation (1,1) logical = 0; % 'factor data' must contain values for startdate -1 in the case we have First Difference (2,5) transformation types and startdate -2 in the case we have Second Difference (3,6) transformation types
        transform_endo char = ''; %transformation codes of varendo variables other than factors (ordering follows 'data' sheet!)
        
        % choose number of factors (principal components) to include
        numpc = 4;
        
        % slow fast scheme for recursive identification (IRFt 2, 3) as in BBE (2005)
        slowfast = 1;  % assign variables in the excel sheet 'factor data' in the 'block' row to "slow" or "fast"
        
        blocks (1,1) logical = 0;  % blocks/categories (1=yes, 0=no), specify in excel sheet
        
        blocknames char = 'slow fast';  % specify in excel sheet 'factor data'
        blocknumpc char = '2 2';        % block-specific number of factors (principal components)
        
        % specify information variables of interest (plot and excel output) (HD & IRFs)
        plotX char = 'INDPRO UNRATE USCONCONF'
        % choose shock(s) to plot
        plotXshock char = '';
        
        % re-tranform transformed variables
        levels (1,1) bear.FAVARlevels = 1; % =0 no re-transformation (default), =1 cumsum, =2 exp cumsum
        retransres = 1;                    % re-transform the candidate IRFs in IRFt4, before checking the restrictions
        
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
        
        function displayScalarObject(obj)
            fprintf('\n <strong> Augment VAR model with factors (true/false)</strong> \n\n')
            favar = matlab.mixin.util.PropertyGroup('FAVAR');
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, favar);
            
            fprintf('\n <strong> FAVAR Properties</strong> \n\n')
            
            % Grab property lists
            props = getPropertyGroups(obj);
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, props);
            
        end
        
        function propgrp = getPropertyGroups(obj)
            
            if obj.FAVAR == 0
                proplist = {'HD', 'IRF', 'FEVD'};
                propgrp = matlab.mixin.util.PropertyGroup(proplist);
            else
                proplist = properties(obj);
                proplist = proplist(~ismember(proplist, {'FAVAR'}));
                if obj.blocks == 0
                    proplist = proplist(~ismember(proplist, {'blocknames','blocknumpc'}));
                end
                propgrp = matlab.mixin.util.PropertyGroup(proplist);
                
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