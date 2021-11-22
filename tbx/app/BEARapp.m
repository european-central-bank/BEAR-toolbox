function BEARapp()
% Launch the appropriate version of the BEAR app
if verLessThan('matlab','9.9')
    eval('bear.app.BEARapp20a');
else
    eval('bear.app.BEARapp21a');
end