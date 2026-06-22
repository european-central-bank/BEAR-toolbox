function varargout = BEARapp()
% Launch the appropriate version of the BEAR app
if verLessThan('matlab','9.9')
    app = bear.app.BEARapp20a;
elseif verLessThan('matlab','9.12')
    eval('app = BEARapp21a;'); %#ok<EVLCS>
else
    eval('app = BEARapp22a;'); %#ok<EVLCS>
end

if nargout == 1
    varargout = {app};
end
