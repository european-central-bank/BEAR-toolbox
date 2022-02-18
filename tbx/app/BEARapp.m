function varargout = BEARapp()
% Launch the appropriate version of the BEAR app
if verLessThan('matlab','9.9')
    eval('app = BEARapp20a');
else
    eval('app = BEARapp21a');
end

if nargout == 1
    varargout = {app};
end