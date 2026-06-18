function favar = initializeFavarResults(opts)
% INITIALIZESTRCIDENT this function initalizes a strcident struct to store
% the results based on the already existing fields on the settings objet
arguments
    opts (1,1) bear.settings.BASEsettings
end

favar.FAVAR     = false;
favar.HDplot    = false;
favar.IRFplot   = false;
favar.FEVDplot  = false;

if isprop(opts, 'favar') && isa(opts.favar, 'bear.settings.favar.FAVARsettings') && opts.favar.FAVAR
    favar = initalizeFavar(opts.favar);
end
end

function favar = initalizeFavar(favarOpt)

p = properties(favarOpt);
for i = 1 : length(p)
    
    favar.(p{i}) = favarOpt.(p{i});
    
end

end