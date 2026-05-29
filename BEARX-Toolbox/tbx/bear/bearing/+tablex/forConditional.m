
%
% tablex.forConditional  Create data timetable and simulation plan timetable for conditional forecast
%

function [dataTbx, planTbx] = forConditional(model, span)

    meta = model.Meta;
    span = datex.span(span(1), span(end));
    lenSpan = numel(span);

    names = [meta.EndogenousNames, meta.ExogenousNames];
    dataColumn = nan(lenSpan, 1);
    data = repmat({dataColumn}, 1, numel(names));
    dataTbx = timetable( ...
        data{:}, ...
        rowTimes=span, ...
        variableNames=names ...
    );

    if nargout == 1
        return
    end

    dataColumn = repmat("", lenSpan, 1);
    data = repmat({dataColumn}, 1, meta.NumEndogenousNames);
    planTbx = timetable( ...
        data{:}, ...
        rowTimes=span, ...
        variableNames=meta.EndogenousNames ...
    );

end%

