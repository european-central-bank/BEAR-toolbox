function strctident = initializeStrctident(opts)
% INITIALIZESTRCIDENT this function initalizes a strcident struct to store
% the results based on the already existing fields on the settings objet
    strctident = struct();
    p = properties(opts.strctident);
    for i = 1 : length(p)
        strctident.(p{i}) = opts.strctident.(p{i});
    end    
end