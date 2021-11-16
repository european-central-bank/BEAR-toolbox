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
        
        % choose shock(s) to plot
        HDplot                  (1,1) logical = 0; % (1=yes, 0=no)
        HDsumShockcontributions (1,1) logical = 1; % sum contributions over shocks (=1), or over variables (=0, standard), only for IRFt2,3\\this option makes no sense in IRFt4,6
        HDplotXblocks                         = 1; % sum contributions of factors blockwise
        HDallsumblock           (1,1) logical = 0; % include all components of HDall(=1) other than shock contributions, but display them sumed under blocks\shocks
        
        IRFplot                 (1,1) logical = 0; % (1=yes, 0=no)
        IRFplotXshock                         = ''; %'FEVDshock';%'FYFF'; % FYFF 'USMP' % we need this atm only for IRFt2,3 provide =varendo for all shocks; in IRFt456 the identified shocks are plotted
        IRFplotXblocks                        = 0;
        
        FEVDplot        (1,1) logical = 0; % (1=yes, 0=no)
        FEVDplotXshock char = '';
        FEVDplotXblocks char = ''; %'EA.factor1 EA.factor2 EA.factor3 EA.factor4 EA.factor5 EA.factor6';
    end
    
    methods
        function obj = FAVARsettings(varargin)
            
            obj = bear.utils.pvset(obj, varargin{:});
            
        end
    end
    
    methods (Access = protected)
        
        function displayScalarObject(obj)
            % Display header
            header = matlab.mixin.CustomDisplay.getSimpleHeader(obj);
            disp(header);
            
            favar = matlab.mixin.util.PropertyGroup('FAVAR');
            
            % Grab property lists
            props = getPropertyGroups(obj);
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, [favar, props]);
            
            fprintf('\n <strong> FAVAR HD Properties</strong> \n\n')
            HD = matlab.mixin.util.PropertyGroup('HDplot');
            if obj.HDplot == 1
                HD = [HD, matlab.mixin.util.PropertyGroup({'HDsumShockcontributions','HDplotXblocks', 'HDallsumblock'})];
            end
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, HD);
            
            fprintf('\n <strong> FAVAR IRF Properties</strong> \n\n')
            IRF = matlab.mixin.util.PropertyGroup('IRFplot');
            if obj.IRFplot == 1
                IRF = [IRF, matlab.mixin.util.PropertyGroup({'IRFplotXshock','IRFplotXblocks'})];
            end
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, IRF);
            
            fprintf('\n <strong> FAVAR FEVD Properties</strong> \n\n')
            FEVD = matlab.mixin.util.PropertyGroup('FEVDplot');
            if obj.FEVDplot == 1
                FEVD = [FEVD, matlab.mixin.util.PropertyGroup({'FEVDplotXshock', 'FEVDplotXblocks'}) ];
            end
            matlab.mixin.CustomDisplay.displayPropertyGroups(obj, FEVD);
            
        end
        
        function propgrp = getPropertyGroups(obj)
            
            proplist = properties(obj);
            
            if obj.FAVAR == 0
                
                idx = false(numel(proplist), 1);
                
            else
                
                idx = true(numel(proplist), 1) & ~ismember(proplist, {'FAVAR','HDplot','HDsumShockcontributions', 'HDplotXblocks', 'HDallsumblock', ...
                    'IRFplot', 'IRFplotXshock', 'IRFplotXblocks', ...
                    'FEVDplot', 'FEVDplotXshock', 'FEVDplotXblocks'});
                
                if obj.blocks == 0
                    idx = idx & ~ismember(proplist, {'blocknames','blocknumpc'});
                end
                
            end
            
            proplist = proplist(idx);
            
            propgrp = matlab.mixin.util.PropertyGroup(proplist);
            
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