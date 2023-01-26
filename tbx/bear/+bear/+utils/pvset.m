function obj = pvset(obj, varargin)

nInputs = numel(varargin);
if rem(nInputs, 2) ~= 0
    error('bear:BASESettings:incorrectNumberOfInputs', 'You need to put an input for each output')
end

for i = 1 : 2 : nInputs
    try
        obj.(varargin{i}) = varargin{i+1};
    catch e
        if ~isprop(obj, varargin{i})
            error('bear:utils:PropertyDoesNotExist','The input %s does not exist', varargin{i})
        else
            rethrow(e)
        end
    end
end

end