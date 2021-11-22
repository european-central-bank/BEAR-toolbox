function BEARapp()
% Launch the appropriate version of the BEAR app
if verLessThan('matlab','9.9')
    eval('BEARapp20a');
else
    eval('BEARapp21a');
end