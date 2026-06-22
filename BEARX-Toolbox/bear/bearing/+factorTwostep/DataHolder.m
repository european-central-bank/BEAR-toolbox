classdef DataHolder < base.DataHolder

    properties
        Reducibles                          % Raw Z data
    end
    
    methods

        function this = DataHolder(meta, dataTable, varargin)
            arguments
                meta (1, 1) factorTwostep.Meta
                dataTable (:, :) timetable
            end
            arguments (Repeating)
                varargin
            end

            this = this@base.DataHolder(meta, dataTable, varargin{:});
            this.Reducibles = tablex.retrieveData(dataTable, meta.ReducibleNames, this.Span, varargin{:});
        end


        function Z = getZ(this, options)
            arguments
                this
                %
                options.Span (1, :) datetime = []
                options.Index (1, :) double = []
            end
            %

            if ~isempty(options.Index)
                index = options.Index;
            else
                index = this.getSpanIndex(options.Span);
            end
           
            sourceZ = this.Reducibles;
            
            numIndex = numel(index);
            Z = nan(numIndex, size(this.Reducibles, 2));

            % Only assign within valid time span
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Z(within, :) = sourceZ(indexWithin, :);
        end%

    end
end