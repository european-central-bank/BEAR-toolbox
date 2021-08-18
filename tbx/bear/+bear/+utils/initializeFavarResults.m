function favar = initializeFavarResults(opts)
% INITIALIZESTRCIDENT this function initalizes a strcident struct to store
% the results based on the already existing fields on the settings objet
favar = struct();
p = opts.getActiveProperties;
for i = 1 : length(p)
    switch p{i}
        case "HD"
            favar.HD   = bear.utils.initializeFavarResults(opts.HD);
        case "IRF"
            favar.IRF  = bear.utils.initializeFavarResults(opts.IRF);
        case "FEVD"
            favar.FEVD = bear.utils.initializeFavarResults(opts.FEVD);
        otherwise
            favar.(p{i}) = opts.(p{i});
    end
end
end