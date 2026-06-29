function varargout = BEARapp()
% Launch the appropriate version of the BEAR app
if isMATLABReleaseOlderThan('R2022a')
    app = bear.app.BEARapp21a;
else
    app = bear.app.BEARapp22a;
end

if nargout == 1
    varargout = {app};
end
