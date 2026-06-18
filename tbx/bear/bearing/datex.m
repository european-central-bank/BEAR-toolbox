
% `datex`
%
% ==Convert SDMX date strings to dates==
%
% Syntax
%
%     dates = datex(sdmxStrings)
%

function d = datex(sdmxStrings)
    arguments
        sdmxStrings (1, :) string
    end
    d = datex.fromSdmx(sdmxStrings);
end%

