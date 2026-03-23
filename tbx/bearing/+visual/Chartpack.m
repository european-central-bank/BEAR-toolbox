
classdef (CaseInsensitiveProperties=true) Chartpack < handle

    properties
        % Span  Date span to plot
        Span (1, :) datetime

        % NamesToPlot  Names of time series to plot
        NamesToPlot (1, :) cell

        % FigureSettings  Settings (name-value pairs) for the figure
        FigureSettings (1, :) cell

        % Captions  Captions for the individual figures
        Captions (1, :) string

        % CaptionSettings  Settings (name-value pairs) for the captions
        CaptionSettings (1, :) cell = { ...
            "interpreter", "none", ...
            "horizontalAlignment", "center", ...
            "verticalAlignment", "top", ...
            "lineStyle", "none", ...
            "fontSize", 14, ...
            "fontWeight", "bold", ...
        }

        % PlotSettings  Settings (name-value pairs) for the plot
        PlotSettings (1, :) cell

        % PlotFunc  Function to use for plotting
        PlotFunc

        % BarStyle  Style for bar plots
        BarStyle (1, 1) string

        % Tiles  Number of tiles (rows, columns) in the figure
        Tiles (1, 2) double
    end


    properties (Dependent)
        NumFigures
        NumPlots
    end


    methods
        function this = Chartpack(options)
            arguments
                options.Span (1, :) datetime
                options.NamesToPlot
                %
                options.FigureSettings (1, :) cell = {}
                options.PlotSettings (1, :) cell = {}
                options.PlotFunc function_handle = @plot
                options.BarStyle (1, 1) string = "stacked"
                options.Tiles (1, :) double = NaN
                options.Captions (1, :) string = string.empty(1, 0)
                options.CaptionSettings (1, :) cell = cell.empty(1, 0)
            end
            this.Span = datex.span(options.Span(1), options.Span(end));
            if iscell(options.NamesToPlot)
                this.NamesToPlot = options.NamesToPlot;
            else
                this.NamesToPlot = {options.NamesToPlot};
            end
            for i = 1 : numel(this.NamesToPlot)
                this.NamesToPlot{i} = reshape(string(this.NamesToPlot{i}), 1, []);
            end
            this.FigureSettings = options.FigureSettings;
            this.Captions = options.Captions;
            this.CaptionSettings = [this.CaptionSettings, options.CaptionSettings];
            this.PlotSettings = options.PlotSettings;
            this.PlotFunc = options.PlotFunc;
            this.BarStyle = options.BarStyle;
            if isequaln(options.Tiles, NaN)
                maxNumPlots = max(this.NumPlots);
                this.Tiles = visual.autoSub(maxNumPlots);
            else
                this.Tiles = options.Tiles;
            end
        end%

        function [figureHandles, plotHandles] = plot(this, table)
            arguments
                this
                table timetable
            end
            %
            figureHandles = cell(1, this.NumFigures);
            plotHandles = cell(1, this.NumFigures);
            for f = 1 : this.NumFigures
                figureHandle = figure(this.FigureSettings{:});
                figureHandles{f} = figureHandle;
                plotHandles{f} = cell(1, numel(this.NamesToPlot{f}));
                for p = 1 : numel(this.NamesToPlot{f})
                    ax = subplot(this.Tiles(1), this.Tiles(2), p);
                    nameToPlot = this.NamesToPlot{f}(p);
                    h = tablex.plot( ...
                        table, nameToPlot, ...
                        "periods", this.Span, ...
                        "axes", ax, ...
                        "plotFunc", this.PlotFunc, ...
                        "barStyle", this.BarStyle, ...
                        "plotSettings", this.PlotSettings ...
                    );
                    plotHandles{f}{p} = h;
                    title(ax, nameToPlot, interpreter="none");
                end
                if numel(this.Captions) >= f
                    annotation( ...
                        "textBox", [0, 0, 1, 1], ...
                        "string", this.Captions(f), ...
                        this.CaptionSettings{:} ...
                    );
                end
            end
        end%
    end


    methods
        function out = get.NumFigures(this)
            out = numel(this.NamesToPlot);
        end%

        function out = get.NumPlots(this)
            out = cellfun(@numel, this.NamesToPlot, uniformOutput=true);
        end%
    end

end

