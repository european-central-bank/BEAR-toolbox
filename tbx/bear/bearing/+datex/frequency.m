%
% FREQUENCY  Get the time frequency of a datetime object
%
% Syntax
% -------
%
%   out = frequency(dt)
%
% Output arguments
% -----------------
%
% * `out` [ numeric ] - Time frequency of the input datetime object.
%

function out = frequency(dt)

    fh = datex.Backend.getFrequencyHandlerFromDatetime(dt);

    if isequaln(fh, NaN)
        out = NaN;
        return
    end

    out = fh.Frequency;

end%

