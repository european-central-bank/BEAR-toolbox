
function varargout = bar(varargin)

    plotFunc = @(varargin) bar(varargin{:}, "stacked");
    [varargout{1:nargout}] = tablex.drawChart(plotFunc, varargin{:});

end%

