function varargout = BEARapp()
% Launch the appropriate version of the BEAR app
if verLessThan('matlab','9.9')
    app = bear.app.BEARapp20a;
elseif verLessThan('matlab','9.12')
    app = bear.app.BEARapp21a;
else
    app = bear.app.BEARapp22a;
end

if nargout == 1
    varargout = {app};
end
