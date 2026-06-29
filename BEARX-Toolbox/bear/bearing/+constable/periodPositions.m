
function positions = periodPositions(ct, periods)

    tablePeriods = ct.Properties.CustomProperties.Periods;
    numRequests = numel(periods);
    positions = nan(size(periods));
    for i = 1 : numRequests
        inx = tablePeriods == periods(i);
        if any(inx)
            positions(i) = find(inx, 1);
        end
    end

end%
