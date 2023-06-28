function dates = dateParser(strDate)

arguments
    strDate (:,1) string
end

firstDate = strDate(1,1);

if contains(firstDate, "y") % Yearly data
    dates = datetime(strDate,'InputFormat',"yyyy'y'", 'Format','yyyy');

elseif contains(firstDate, "q") % Quarterly data
    dates = datetime(strDate, 'InputFormat','yyyyQQQ','Format','yyyy''q''Q');

elseif contains(firstDate, "m") % Monthly data
    dates = datetime(strDate,'InputFormat',"yyyy'm'MM", 'Format','yyyy''m''M');

elseif contains(firstDate, 'd') % Daily data
    dates = datetime(strDate,'InputFormat',"uuuu'd'D", 'Format','yyyy''d''D');

elseif contains(firstDate, 'w')
    dates = arrayfun(@(x) strsplit(x, 'w'), strDate, UniformOutput = false);
    dates = cellfun(@(x) datetime(x(1),'InputFormat','yyyy') + calweeks(str2double(x(2))), dates);
else
    dates = strDate;
end

end