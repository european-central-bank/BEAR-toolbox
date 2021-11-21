function app = BEARapp()
% Launch the appropriate version of the BEAR app
if verLessThan('matlab','9.9')
    app = eval('BEARapp20a');
else
    app = eval('BEARapp21a');
end