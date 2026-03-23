
% model.Meta  Meta information about reduced-form and structural models

classdef Meta < base.Meta

    % Reduced-form model meta information
    properties (SetAccess=protected)
        %
        % ReducibleNames  Names of reducible variables in factor models
        ReducibleNames (1, :) string 

        % ReducibleBlocks  Names of blocks the corresponding reducibles
        % belong to
        ReducibleBlocks (1, :) string

        % Blocktype for FAVARS
        BlockType (1,:) string

        % NumFactors  Number of factors to be formed from reducibles
        NumFactors struct 

    end


    properties (Dependent)
    
        FactorNames
        NumFactorNames
        NumReducibleNames

    end


    methods
        function this = Meta(options)

        arguments

            options.endogenousConcepts (1, :) string {mustBeNonempty}
            options.estimationSpan (1, :) datetime {mustBeNonempty}
    
            options.exogenousNames (1, :) string = string.empty(1, 0)
            options.units (1, :) string = ""
            options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
            options.intercept (1, 1) logical = true
            options.shockConcepts (1, :) string = string.empty(1, 0)
            options.shocks (1, :) string = string.empty(1, 0)
            options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
    
            options.reducibleNames (1, :) string = string.empty(1, 0)
            options.reducibleBlocks (1, :) string = string.empty(1, 0)
            options.blockType (1,1) string {mustBeMember(options.blockType, ["blocks", "slowfast"])} = "blocks"
            options.numFactors struct = struct()
        end%

            this@base.Meta( ...
                'endogenousConcepts', options.endogenousConcepts, ...
                'estimationSpan', options.estimationSpan, ...
                'exogenousNames', options.exogenousNames, ...
                'order', options.order, ...
                'intercept', options.intercept, ...
                'shockConcepts', options.shockConcepts, ...
                'shocks', options.shocks, ...
                'identificationHorizon', options.identificationHorizon ...
            );

            this.ReducibleNames = options.reducibleNames;
            this.ReducibleBlocks = options.reducibleBlocks;
            this.BlockType = options.blockType; 
            this.NumFactors = options.numFactors;

            this.populateShockConcepts(options.shockConcepts);         
            this.catchDuplicateNames();


        end%


        function ResidualNames = getResidualNames(this)

                ResidualNames = meta.concatenate(this.ResidualPrefix, [this.FactorNames, this.EndogenousNames]);
                
        end%


        function populateShockConcepts(this, shockConcepts)

            if ~isempty(shockConcepts)
                this.ShockConcepts = shockConcepts;
            else
                this.ShockConcepts = meta.autogenerateShockConcepts(this.NumEndogenousConcepts + ...
                    this.NumFactorNames);
            end
            
            if this.NumShockNames ~= this.NumEndogenousNames + this.NumFactorNames
                error("Number of shock names must match number of endogenous variables, including factors");
            end
        
        end%
    

    end

    methods (Access=protected)

        function catchDuplicateNames(this)
            allNames = [ ...
                this.EndogenousNames, ...
                this.ExogenousNames, ...
                this.ReducibleNames, ...
                this.ShockNames ...
            ];
            if numel(allNames) ~= numel(unique(allNames))
                nonuniques = textual.nonunique(allNames);
                error("Duplicate model name(s): " + join(nonuniques, ", "));
            end
        end%


    end


    % Reduced-form dependent properties
    methods

        function out = get.FactorNames(this)
            out = strings(1,0);
            bnames = sort(unique(this.ReducibleBlocks));
            for ii = 1:numel(bnames)
                out = [out, bnames(ii) + "_Factor" + string(1:this.NumFactors.(bnames(ii)))];
            end
        end%

        function num = get.NumReducibleNames(this)
            num = numel(this.ReducibleNames);
        end%

        function num = get.NumFactorNames(this)
            num = numel(this.FactorNames);
        end%


    end

end

