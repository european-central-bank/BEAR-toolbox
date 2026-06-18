
function varargout = plot(varargin)

    plotFunc = @plot;
    [varargout{1:nargout}] = tablex.drawChart(plotFunc, varargin{:});

end%

