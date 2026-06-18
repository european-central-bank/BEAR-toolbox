function [status, Zcell, Msg]=checkZeroRestriction_lj(meta, instantZerosTbx)

numShock = meta.NumShocks;
shockNames = meta.ShockNames';

% Identify the restriction matrices
Zcell=cell(1,numShock);

% check for empty columns in signrestable
count=0;
for ii=1:size(instantZerosTbx,2)
    restablecat=cat(2,instantZerosTbx{:,ii});
    if isempty(restablecat)==0
        count=count+1;
    end
end

status = 1;
Msg = '';

if count>0 % if we found something in the table then the sign res routine is activated

    %% zero res
    for ii=1:numShock % loop over shocks
        % count the number of zero restrictions in this column
        numzerores=sum(instantZerosTbx{:,ii}==0);
        % if there are too many zero restrictions for the column, return an error
        if numzerores>numShock-ii

            status = 0;
            Msg=['You have requested ' num2str(numzerores) ' zero restrictions for shock ' shockNames{ii} ', but at most ' num2str(numShock-ii) ' such restrictions can be implemented.'];
            return

        elseif numzerores>0

            Zcell{ii} = double(instantZerosTbx{:,ii}==0)';

        end
    end

end
