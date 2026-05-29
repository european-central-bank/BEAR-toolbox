function strctident = initializeStrctident(opts)
% INITIALIZESTRCIDENT this function initalizes a strcident struct to store
% the results based on the already existing fields on the settings object

strctident = struct();
if ~isempty(opts.strctident)
    p = properties(opts.strctident);
    for i = 1 : length(p)
        strctident.(p{i}) = opts.strctident.(p{i});
    end
end

end