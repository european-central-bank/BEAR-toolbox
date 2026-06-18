function [signrestable,signresperiods,signreslabels,strctident]=checkZeroRestriction_lj(meta)

n = meta.NumEndogenousNames;
endo = meta.EndogenousNames';
strctident = struct();
% preliminary tasks
pref.excelFile = 'restrictions.xlsx';

% initiate the cells signrestable, signresperiods and signreslabels
signrestable=cell(n,n);
signresperiods=cell(n,n);
signreslabels=cell(n,1);
signreslabels_shocksindex=[];
% load the data from Excel
% sign restrictions values
[~,~,strngs1]=xlsread(pref.excelFile,'sign res values');
[~,~,strngs2]=xlsread(pref.excelFile,'sign res periods');
% replace NaN entries by blanks
strngs1(cellfun(@(x) any(isnan(x)),strngs1))={[]};
strngs2(cellfun(@(x) any(isnan(x)),strngs2))={[]};
% convert all numeric entries into strings
strngs1(cellfun(@isnumeric,strngs1))=cellfun(@num2str,strngs1(cellfun(@isnumeric,strngs1)),'UniformOutput',0);
strngs2(cellfun(@isnumeric,strngs2))=cellfun(@num2str,strngs2(cellfun(@isnumeric,strngs2)),'UniformOutput',0);
% identify the non-empty entries (pairs of rows and columns), changed the
% routine here
% empty strngs1 columns and rows, to make sure empty rows (with empty strings) are dismissed
for ii=1:size(strngs1,1) %rows
    strngs1emptyrows(ii,1)=isempty(cat(2,strngs1{ii,:}));
end
strngs1emptyrows_index=find(strngs1emptyrows==0);

for ii=1:size(strngs1,2) %columns
    strngs1emptycolumns(1,ii)=isempty(cat(2,strngs1{:,ii}));
end
strngs1emptycolumns_index=find(strngs1emptycolumns==0);
%
strngs1=strngs1(strngs1emptyrows_index,strngs1emptycolumns_index);

% empty strngs2 columns and rows, to make sure empty rows (with empty strings) are dismissed
for ii=1:size(strngs2,1) %rows
    strngs2emptyrows(ii,1)=isempty(cat(2,strngs2{ii,:}));
end
strngs2emptyrows_index=find(strngs2emptyrows==0);

for ii=1:size(strngs2,2) %columns
    strngs2emptycolumns(1,ii)=isempty(cat(2,strngs2{:,ii}));
end
strngs2emptycolumns_index=find(strngs2emptycolumns==0);
%
strngs2=strngs2(strngs2emptyrows_index,strngs2emptycolumns_index);

[nerows1,neclmns1]=find(~cellfun('isempty',strngs1));
[nerows2,neclmns2]=find(~cellfun('isempty',strngs2));
% count the number of such entries
neentries1=size(nerows1,1);
neentries2=size(nerows2,1);

% all these entries contrain strings: fix them to correct potential user formatting errors
% loop over entries (value table)
for ii=1:neentries1
    strngs1{nerows1(ii,1),neclmns1(ii,1)}=bear.utils.fixstring(strngs1{nerows1(ii,1),neclmns1(ii,1)});
end

% loop over entries (period table)
for ii=1:neentries2
    strngs2{nerows2(ii,1),neclmns2(ii,1)}=bear.utils.fixstring(strngs2{nerows2(ii,1),neclmns2(ii,1)});
end


%% check if sign, zero, magntiude restrictions are activated at all
for ii=1:n % loop over endogenous variables
    % one is the column label, the other is the row label
    [r,c]=find(strcmp(strngs1,endo{ii,1}));
    if ~isempty(r)
        rows(ii,1)=max(r);
        % the greatest number in c corresponds to the column of the row labels: record it
        clmns(ii,1)=max(c);
    else
        rows(ii,1)=0;
        % the greatest number in c corresponds to the column of the row labels: record it
        clmns(ii,1)=0;
    end
end

% now recover the values for the cell signrestable
for ii=1:n % loop over endogenous (rows)
   for jj=1:n % loop over endogenous (columns)
        if rows(ii,1)~=0 && clmns(jj,1)~=0
            signrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
        end
    end
end

% check for empty columns in signrestable
count=0;
for ii=1:size(signrestable,2)
    signrestablecat=cat(2,signrestable{:,ii});
    if isempty(signrestablecat)==0
        count=count+1;
    end
end

if count>0 % if we found something in the table then the sign res routine is activated
    signrestable=cell(n,n);
    clear signrestablecat
    %% sign restriction values
    % loop over endogenous variables
    for ii=1:n
        % for each variable, there should be two entries in the table corresponding to its name
        % one is the column lable, the other is the row label
        [r,c]=find(strcmp(strngs1,endo{ii,1}));
        % if it is not possible to find two entries, return an error
        if size(r,1)<2
            message=['Endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''sign res values'' sheet of the Excel data file is properly filled.'];
            msgbox(message,'Sign restriction error');
            error('programme termination: sign restriction error');   
        end
        % otherwise, the greatest number in r corresponds to the row of the column labels: record it
        rows(ii,1)=max(r);
        % the greatest number in c corresponds to the column of the row labels: record it
        clmns(ii,1)=max(c);
    end

    % now recover the values for the cell signrestable
    % loop over endogenous (rows)
    for ii=1:n
        % loop over endogenous (columns)
        for jj=1:n
            signrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
        end
    end

    % empty sign res table columns
    for ii=1:size(signrestable,2)
        strctident.signrestableempty(ii,1)=isempty(cat(2,signrestable{:,ii}))==1;
    end

    %% zero res
    % loop over columns
    for ii=1:n
        % count the number of zero restrictions in this column
        numzerores=sum(strcmp(signrestable(:,ii),'0'));
        % if there are too many zero restrictions for the column, return an error
        if numzerores>n-ii
            temp=['You have requested ' num2str(numzerores) ' zero restrictions in column ' num2str(ii) ' of the restriction matrix, but at most ' num2str(n-ii) ' such restrictions can be implemented.'];
            msgbox(temp,'Zero restriction issue');
            error('Zero restriction error');
        end
    end

    %% sign restriction periods
    % recover the rows and columns of each endogenous variable
    % loop over endogenous variables
    for ii=1:n
        % for each variable, there should be two entries in the table corresponding to its name
        % one is the column lable, the other is the row label
        [r,c]=find(strcmp(strngs2,endo{ii,1}));
        % if it is not possible to find two entries, return an error
        if size(r,1)<2
            message=['Endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''sign res periods'' sheet of the Excel data file is properly filled.'];
            msgbox(message,'Sign restriction error');
            error('programme termination: sign restriction error');   
        end
        % the greatest number in r corresponds to the row of the column labels: record it
        rows2(ii,1)=max(r);
        % the greatest number in c corresponds to the column of the row labels: record it
        clmns2(ii,1)=max(c);
    end

    % now recover the values for the cell signresperiods
    % loop over endogenous (rows)
    for ii=1:n
        % loop over endogenous (columns)
        for jj=1:n
            % record the value
            signresperiods{ii,jj}=str2num(strngs2{rows2(ii,1),clmns2(jj,1)});
        end
    end


    % recover the labels, if any
    % loop over endogenous (columns)
    for ii=1:n
        % the label for shock ii is found in strngs2, row 3 and column 'clmns(ii,1)'
        temp=strngs1{min(rows)-2,clmns(ii,1)};    

        % if empty, give the generic name 'shock ii'
        if isempty(temp)
            signreslabels{ii,1}=['shock ' num2str(ii)];
            if strctident.signrestableempty(ii)==0 % restrictions, however no label is found, count this column
                signreslabels_shocksindex=[signreslabels_shocksindex; ii];
            end
        % else, record the name
        else
            if strctident.signrestableempty(ii)==0 % label and restictions found
                signreslabels{ii,1}=temp;
                signreslabels_shocksindex=[signreslabels_shocksindex; ii];
            elseif strctident.signrestableempty(ii)==1 % label, however no restriction is found, ignore this column
                signreslabels{ii,1}=['shock ' num2str(ii)];
            end
        end
    end

    % save the shock index to later determine the number of identified shocks
    strctident.signreslabels_shocksindex=unique(signreslabels_shocksindex);
    strctident.signreslabels_shocks=signreslabels(strctident.signreslabels_shocksindex);
    strctident.signreslabels=signreslabels;


    %% Preliminiaries for irfres function
    % now identify all the periods concerned with restrictions
    % first expand the non-empty entries in signresperiods since they are only expressed in intervals: transform into list
    % for instance, translate [1 4] into [1 2 3 4]; I don't think this can done without a loop
    temp=cell2mat(signresperiods(~cellfun(@isempty,signresperiods)));
    periods=[];

    for ii=1:size(temp,1)
        periods=[periods temp(ii,1):temp(ii,2)];
    end

    % suppress duplicates and sort
    strctident.periods=sort(unique(periods))';
    % count the total number of restriction periods (required for IRF matrix)
    nperiods=size(strctident.periods,1);

    % Identify the restriction matrices
    strctident.Zcell=cell(1,n);


    % Check if value and periods restrictions correspond to each other
    if sum(sum(~cellfun(@isempty,signresperiods) == ~cellfun(@isempty,signrestable))) == n^2
        % All cells with sign restrictions also specify the horizon over which
        % these are applied
    else
        disp('Warning: Value restrictions do not correspond to period restrictions one to one')
        pause(0.1)
    end

    % loop over rows and columns of the period matrix
    for ii=1:n
        for jj=1:n
            % if entry (ii,jj) of the period matrix and of the value matrix is not empty...
            if ~isempty(signresperiods{ii,jj}) && ~isempty(signrestable{ii,jj})
                % ... then there is a restriction over one (or several) periods
                % loop overt those periods
                for kk=signresperiods{ii,jj}(1,1):signresperiods{ii,jj}(1,2)
                    % identify the position of the considered period within the list of all periods (required to build the matrix)
                    position=find(strctident.periods==kk);
                    % now create the restriction matrix: 
                    if strcmp(signrestable{ii,jj},'0')
                        % ... then input a 1 entry in the corresponding Z matrix
                        strctident.Zcell{1,jj}=[strctident.Zcell{1,jj};zeros(1,n*nperiods)];
                        strctident.Zcell{1,jj}(end,(position-1)*n+ii)=1;
                    end
                end
            end
        end
    end

    %% Check kind of restrictions
    % now check what kind of restrictions apply among sign, zero and magnitude restrictions

    % similarly check for zero restrictions
    if sum(~cellfun(@isempty,strctident.Zcell))~=0
        strctident.zerores=1;
        strctident.hbartext_zerores='zero, ';
    else
        strctident.zerores=0;
        strctident.hbartext_zerores='';
    end

end
