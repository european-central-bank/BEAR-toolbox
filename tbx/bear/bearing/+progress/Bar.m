
% progress.Bar  Display command line progress bar

classdef Bar < handle
    properties
        Active (1, 1) logical = true
        Title (1, 1) string = ""
        TitleRow (1, 1) string = ""
        NumProgress = 50
        TotalCount = 0
        RunningCount = 0
        LastIndicatorRow = ''
        LastNumFullBars = 0
        Done = false
        Diary = cell.empty(0, 2)
    end


    properties (Constant)
        FULL_BAR = char(8213)
        TIP_BAR = char(9724)
        EMPTY_BAR = char(8213)
        LEFT_EDGE = ' '
        RIGHT_EDGE = ' '
    end


    methods
        function this = Bar(title, totalCount, options)
            arguments
                title (1, 1) string = ""
                totalCount (1, 1) double {mustBeNonnegative} = 0
                options.Active (1, 1) logical = true
            end
            this.Title = title;
            this.TotalCount = totalCount;
            this.RunningCount = 0;
            this.Active = options.Active;
            this.TitleRow = string(repmat(' ', 1, strlength(this.LEFT_EDGE))) + this.Title;
            this.Diary = cell.empty(0, 2);
            this.start();
        end%


        function start(this)
            if ~this.Active || this.Done
                return
            end
            fprintf("\n%s", this.TitleRow);
            this.LastIndicatorRow = sprintf('%s%*s%s', this.LEFT_EDGE, this.NumProgress, ' ', this.RIGHT_EDGE);
            fprintf('\n');
            fprintf('%s', this.LastIndicatorRow);
            this.update(0);
        end%


        function update(this, varargin)
            if ~this.Active || this.Done
                return
            end
            [numCompleted, permille] = getNumBars(this, varargin{:});
            fullBars = repmat(this.FULL_BAR, 1, numCompleted);
            if numCompleted<this.NumProgress
                tipBar = this.TIP_BAR;
                emptyBars = repmat(this.EMPTY_BAR, 1, this.NumProgress-numCompleted-1);
            else
                tipBar = '';
                emptyBars = repmat(this.EMPTY_BAR, 1, this.NumProgress-numCompleted);
            end
            indicatorRow = [
                this.LEFT_EDGE, fullBars, tipBar, emptyBars, this.RIGHT_EDGE ...
                sprintf(' %g%% ', round(permille/10))
                ];
            if ~isequal(indicatorRow, this.LastIndicatorRow)
                deleteLastIndicatorRow(this);
                fprintf('%s', indicatorRow);
            end
            this.LastIndicatorRow = indicatorRow;
            this.Diary(end+1, :) = {permille, indicatorRow};
            if permille==1000
                done(this);
            end
        end%


        function done(this)
            if ~this.Active || this.Done
                return
            end
            if ~this.Done
                this.Done = true;
                fprintf('\n\n');
            end
        end%


        function increment(this, add)
            if nargin<2
                add = 1;
            end
            this.RunningCount = this.RunningCount + add;
            if this.RunningCount>this.TotalCount
                this.RunningCount = this.TotalCount;
            end
            update(this, this.RunningCount/this.TotalCount);
        end%


        function deleteLastIndicatorRow(this)
            fprintf(repmat('\b', 1, numel(this.LastIndicatorRow)));
        end%


        function [numCompleted, permille] = getNumBars(this, varargin)
            if numel(varargin)==1
                fraction = varargin{1};
            else
                position = varargin{1};
                index = varargin{2};
                fraction = nnz(index(1:position)) / nnz(index);
            end
            if ~isfinite(fraction)
                fraction = 1;
            end
            numCompleted = floor(this.NumProgress*fraction);
            permille = round(fraction*1000);
        end%
    end
end

