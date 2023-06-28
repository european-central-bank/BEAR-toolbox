function tb = parseTableContent(myObj)

if isstring(myObj)

    tb = cellstr(myObj);

elseif isnumeric(myObj)

    tb = cell(size(myObj));
    for i = 1 : size(tb,1)
        for j = 1 : size(tb,2)
            if isnan(myObj(i,j))
                tb{i,j} = '';
            else
                tb{i,j} = num2str(myObj(i,j));
            end
        end
    end

else 
    error('bear:utils:parseTable:incorrectType', 'input object must be either cell or numeric')
end