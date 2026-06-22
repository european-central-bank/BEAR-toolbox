
function tbx = forLongRunDummies(meta)
%
    % Create a table with endogenous variables in rows and in columns,
    % initialized to all 0s.
    data = repmat({zeros(meta.NumEndogenousNames, 1)}, 1, meta.NumEndogenousNames);
    tbx = table( ...
        data{:}, ...
        rowNames=meta.EndogenousNames, ...
        variableNames=meta.EndogenousNames ...
        );
%
%tbx = tablex.setCheckConsistency(tbx, @checkConsistency);
%
end%


% function checkConsistency(tbx)

% end%

