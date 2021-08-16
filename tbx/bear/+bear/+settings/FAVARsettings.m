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
        
        % slow fast scheme for recursive identification (IRFt 2, 3) as in BBE (2005)
        slowfast = 1;  % assign variables in the excel sheet 'factor data' in the 'block' row to "slow" or "fast"
        
        
        blocknames = 'slow fast';  % specify in excel sheet 'factor data'
        blocknumpc = '2 2';        % block-specific number of factors (principal components)
        
        % specify information variables of interest (plot and excel output) (HD & IRFs)
        plotX = 'IPS10 PMCP LHEM LHUR'
        plotXshock = '';
        
        levels (1,1) bear.FAVARlevels = 1; % =0 no re-transformation (default), =1 cumsum, =2 exp cumsum
        retransres = 1;                    % re-transform the candidate IRFs in IRFt4, before checking the restrictions
        
        HD   (1,1) bear.settings.favarHDsettings   = bear.settings.favarHDsettings
        IRF  (1,1) bear.settings.favarIRFsettings  = bear.settings.favarIRFsettings
        FEVD (1,1) bear.settings.favarFEVDsettings = bear.settings.favarFEVDsettings
    end
    
    properties % These properties need to be reviewed
        irf_record
        pltX (:,:) cell = {};
        trnsfrm_endo (:,1) cell = {};
        transformationindex
        informationdatestrings
        informationvariablestrings
        informationstartlocation
        informationendlocation
        plot_transform
        transformation1
        transformation2
        transformation3
        transformation4
        transformation5
        transformation6
        transformation7
        nfactorvar
        X
        informationendlocation_sub
        X_stddev
        X_temp
        l
        variaexpl
        sumvariaexpl
        factorlabels
        XZ
        XZ_full
        X_full
        npltX
        pX
        plotX_index
        data_exfactors
        variablestrings_exfactors_index
        variablestrings_exfactors
        variablestrings_factorsonly_index
        variablestrings_factorsonly
        indexnM
        transformationindex_endo_temp
        data_exfactors_transformed
        data_exfactors_stddev_temp
        transformationindex_endo
        data_exfactors_stddev
        data_exfactors_temp
        data_exfactors_full
        data_full
        numdata_exfactors
        XZ_rotated
        L
        evf
        Sigma
        XY
        bvar
        XZ0mean
        XZ0var
        
        X_gibbs
        Y_gibbs
        FY_gibbs
        L_gibbs
        R2_gibbs
        
        bvarXY
    end
    
    methods
        function obj = FAVARsettings(varargin)
            
            obj = bear.utils.pvset(obj, varargin{:});
            
        end
    end
    
    methods (Access = protected)
        
        function propgrp = getPropertyGroups(obj)
            
            if obj.FAVAR == 0
                proplist = {'FAVAR', 'HD', 'IRF', 'FEVD'};
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