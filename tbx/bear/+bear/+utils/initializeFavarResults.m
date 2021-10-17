function favar = initializeFavarResults(opts)
% INITIALIZESTRCIDENT this function initalizes a strcident struct to store
% the results based on the already existing fields on the settings objet
arguments
    opts (1,1) bear.settings.BASEsettings
end

favar.FAVAR     = false;
favar.HD.plot   = false;
favar.IRF.plot  = false;
favar.FEVD.plot = false;

if isprop(opts, 'favar') && isa(opts.favar, 'bear.settings.FAVARsettings')
    favar = initalizeFavar(opts.favar);
end
end

function favar = initalizeFavar(favarOpt)

p = favarOpt.getActiveProperties;
    for i = 1 : length(p)
        switch p{i}
            case "HD"
                favar.HD   = initalizeFavar(favarOpt.HD);
            case "IRF"
                favar.IRF  = initalizeFavar(favarOpt.IRF);
            case "FEVD"
                favar.FEVD = initalizeFavar(favarOpt.FEVD);
            otherwise
                favar.(p{i}) = favarOpt.(p{i});
        end
    end

end