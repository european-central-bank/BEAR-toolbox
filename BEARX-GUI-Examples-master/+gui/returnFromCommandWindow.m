function returnFromCommandWindow(varargin) %#ok<INUSD>
% Harness shim: the real `gui.returnFromCommandWindow` only exists inside
% the BEARX GUI application and re-focuses it. When running master.m
% scripts headless from this harness, it has nothing to do.
end
