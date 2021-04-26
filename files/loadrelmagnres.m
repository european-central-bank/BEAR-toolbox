function [relmagnrestable,relmagnresperiods,signreslabels,strctident,favar]=loadrelmagnres(n,endo,pref,favar,IRFt,strctident)

% preliminary tasks

% initiate the cells relmagrestable and relmagresperiods
relmagnrestable=cell(n,n);
relmagnresperiods=cell(n,n);
signreslabels=strctident.signreslabels;
signreslabels_shocksindex=strctident.signreslabels_shocksindex;
% load the data from Excel
% sign restrictions values
[~,~,strngs1]=xlsread('data.xlsx','relmagn res values');
% replace NaN entries by blanks
strngs1(cellfun(@(x) any(isnan(x)),strngs1))={[]};
% convert all numeric entries into strings
strngs1(cellfun(@isnumeric,strngs1))=cellfun(@num2str,strngs1(cellfun(@isnumeric,strngs1)),'UniformOutput',0);
% identify the non-empty entries (pairs of rows and columns), changed the routine here
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


[nerows1,neclmns1]=find(~cellfun('isempty',strngs1));

% count the number of such entries
neentries1=size(nerows1,1);
% all these entries contrain strings: fix them to correct potential user formatting errors
% loop over entries (value table)
for ii=1:neentries1
strngs1{nerows1(ii,1),neclmns1(ii,1)}=fixstring(strngs1{nerows1(ii,1),neclmns1(ii,1)});
end

%% check if relative magnitude restrictions are activated at all
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

% now recover the values for the cell relmagnrestable
for ii=1:n % loop over endogenous (rows)
   for jj=1:n % loop over endogenous (columns)
       if rows(ii,1)~=0 && clmns(jj,1)~=0
            relmagnrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
       end
    end
end

% check for empty columns in relmagn res table
count=0;
for ii=1:size(relmagnrestable,2)
    relmagnrestablecat=cat(2,relmagnrestable{:,ii});
     if isempty(relmagnrestablecat)==0
        count=count+1;
    end
end

if count==0 && favar.FAVAR==0 % we found no relmagn res (this test is not applicable to the favar restrictions)
    strctident.relmagnres=0;
    strctident.hbartext_relmagnres='';
    strctident.favar_relmagnres=0;
    strctident.hbartext_favar_relmagnres='';
    strctident.relmagnrestableempty=ones(n,1);
    strctident.favar_relmagnrestableempty=ones(n,1);
else % if we found something in the table then the relmagn routine is activated
    relmagnrestable=cell(n,n);
    clear relmagnrestablecat
%% relative magnitude restriction values
% loop over endogenous variables
for ii=1:n
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[r,c]=find(strcmp(strngs1,endo{ii,1}));
   % if it is not possible to find two entries, return an error
   if size(r,1)<2
   message=['Endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''relmagn res values'' sheet of the Excel data file is properly filled.'];
   msgbox(message,'Relative magnitude restriction error');
   error('programme termination: relative magnitude restriction error');   
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
    relmagnrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
   end
end    
    

 % identify empty relmagn res table columns
for ii=1:size(relmagnrestable,2)
    strctident.relmagnrestableempty(ii,1)=isempty(cat(2,relmagnrestable{:,ii}))==1;
end


% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in sign res table
            if strctident.relmagnrestableempty(1,1)==0
                for ll=1:size(relmagnrestable,1)
                relmagnrestable{ll,1}='';
                end
                signreslabels{1,1}=strcat('IV Shock (',strctident.Instrument,')');
                signreslabels_shocksindex(1,1)=1;
                message=['The restrictions in the first column of the "relmagn res values" table are ignored. This is the IV shock.'];
                msgbox(message,'Relative magnitude restriction warning');
            end
end

% magnitude restriction periods
[~,~,strngs2]=xlsread('data.xlsx','relmagn res periods');
strngs2(cellfun(@(x) any(isnan(x)),strngs2))={[]};
strngs2(cellfun(@isnumeric,strngs2))=cellfun(@num2str,strngs2(cellfun(@isnumeric,strngs2)),'UniformOutput',0);
[nerows2,neclmns2]=find(~cellfun('isempty',strngs2));
neentries2=size(nerows2,1);
% loop over entries (period table)
for ii=1:neentries2
strngs2{nerows2(ii,1),neclmns2(ii,1)}=fixstring(strngs2{nerows2(ii,1),neclmns2(ii,1)});
end

% recover the rows and columns of each endogenous variable
% loop over endogenous variables
for ii=1:n
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[r,c]=find(strcmp(strngs2,endo{ii,1}));
   % if it is not possible to find two entries, return an error
   if size(r,1)<2
   message=['Endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''relmagn res periods'' sheet of the Excel data file is properly filled.'];
   msgbox(message,'Relative magnitude restriction error');
   error('programme termination: relative magnitude restriction error');   
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
   relmagnresperiods{ii,jj}=str2num(strngs2{rows2(ii,1),clmns2(jj,1)});
   end
end

% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in sign res table
        for ii=1:size(relmagnresperiods,2)
            relmagnresperiodscat=cat(2,relmagnresperiods{:,ii});
            if ii==1 && isempty(relmagnresperiodscat)==0
                for ll=1:size(relmagnresperiods,1)
                relmagnresperiods{ll,ii}='';
                end
                message=['The restrictions in the first column of the "relmagn res periods" table are ignored. This is the IV shock.'];
                msgbox(message,'Relative magnitude restriction warning');
            end
        end
end


% however if we have no sign restrictions at all, but we have rel magn restrictions then generate them from the "relmagn res values" table
if strctident.signres==0 && strctident.zerores==0 && strctident.magnres==0 && strctident.favar_signres==0 && strctident.favar_zerores==0 && strctident.favar_magnres==0
    
% loop over endogenous (columns)
for ii=1:n
% the label for shock ii is found in strngs2, row 3 and column 'clmns(ii,1)'
temp=strngs1{min(rows)-2,clmns(ii,1)};
   % if empty, give the generic name 'shock ii'
   if isempty(temp)
       if IRFt==6 && ii==1 % special case for the IV shock in IRFt==6
        signreslabels{ii,1}=strcat('IV Shock (',strctident.Instrument,')');
        signreslabels_shocksindex=[signreslabels_shocksindex; ii];
       else
           signreslabels{ii,1}=['shock ' num2str(ii)];
           if strctident.relmagnrestableempty(ii)==0 % restrictions, however no label is found, count this column
           signreslabels_shocksindex=[signreslabels_shocksindex; ii];
           end
       end
   % else, record the name
   else
       if IRFt==6 && ii==1 % special case for the IV shock in IRFt==6
       signreslabels{ii,1}=strcat('IV Shock (',strctident.Instrument,')');
       signreslabels_shocksindex=[signreslabels_shocksindex; ii];
       else
       if strctident.relmagnrestableempty(ii)==0 % label and restictions found
            signreslabels{ii,1}=temp;
            signreslabels_shocksindex=[signreslabels_shocksindex; ii];
       elseif strctident.relmagnrestableempty(ii)==1 % label, however no restriction is found, ignore this column
            signreslabels{ii,1}=['shock ' num2str(ii)];
       end
       end
   end
end
% save the shock index to later determine the number of identified shocks
strctident.signreslabels_shocksindex=unique(signreslabels_shocksindex);
strctident.signreslabels_shocks=signreslabels(strctident.signreslabels_shocksindex);
strctident.signreslabels=signreslabels;
end



%% Preliminaries for relative magnitude restrictions
% now identify all the periods concerned with relative magnitude
% restrictions
% first expand the non-empty entries in magresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4]; 
temp=cell2mat(relmagnresperiods(~cellfun(@isempty,relmagnresperiods)));
mperiods=[];
for ii=1:size(temp,1)
    mperiods=[mperiods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
strctident.mperiods=sort(unique(mperiods))';
% count the total number of restriction periods (required for IRF matrix)
%rmperiods=size(strctident.mperiods,1);

%create matrix entry for relative magnitude restrictions
[r] = find(~cellfun('isempty',relmagnrestable));
%2. Indentify which entry corresponds to the positive magnitude
%restriction (which shock is supposed to have a larger impact on which
%variable)
num_magres=length(r)/2; %number of relative magnitude restrictions

strctident.rowsS = [];
strctident.columnsS = [];
for jj=1:num_magres %%loop over number of magnitude restrictions
strtemp = strcat('S',num2str(jj)); %%find entry in the table corresponding to the Stronger than restriction
Stronger = strcmp(relmagnrestable, strtemp);
[rowS,columnS] = find(Stronger==1);
strctident.rowsS = [strctident.rowsS rowS];
strctident.columnsS = [strctident.columnsS columnS]; 
end 

strctident.rowsW = [];
strctident.columnsW = [];
for jj=1:num_magres
strtemp = strcat('W',num2str(jj));
Weaker = strcmp(relmagnrestable, strtemp);
[rowW,columnW] = find(Weaker==1);
strctident.rowsW = [strctident.rowsW rowW];
strctident.columnsW = [strctident.columnsW columnW]; 
end

% check number of W and S restrictions
if size(strctident.columnsW,1)~=size(strctident.columnsS,1)
    strctident.relmagnres=0;
    strctident.hbartext_relmagnres='';    
    message=['S and W restrictions are inconsistent. Relative magnitude restrictions are ignored.'];
    msgbox(message,'Relative magnitude restriction warning');
else
    
% check for relative magnitude restrictions
if isempty(strctident.columnsW)==0 && isempty(strctident.columnsS)==0
    strctident.relmagnres=1;
    strctident.hbartext_relmagnres='rel. magnitude, ';
    
% check if shocks are not identified via sign res or favar sign res, but via relmagn res
% check for empty signres, favar_signres and non-empty relmagn res shocks
for ii=1:size(strctident.signreslabels,1)
    if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==0
        % add them to the list of identified shocks in this case
        if isempty(strngs1{min(rows)-2,clmns(ii,1)})==0
        strctident.signreslabels{ii,1}=strngs1{min(rows)-2,clmns(ii,1)}; % take the label provided in the table in this case
        else
        strctident.signreslabels{ii,1}=['shock ' num2str(ii)];    % or generate a label
        end
        strctident.signreslabels_shocksindex=[strctident.signreslabels_shocksindex; ii]; % add it in the shocksindex
    end
end
% update the output in strctident
strctident.signreslabels_shocksindex=unique(strctident.signreslabels_shocksindex);
strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
signreslabels=strctident.signreslabels;

elseif isempty(strctident.columnsW)==1 && isempty(strctident.columnsS)==1 % we found no relmagn res
    strctident.relmagnres=0;
    strctident.hbartext_relmagnres='';
end

end

%% FAVAR
if favar.FAVAR==1
    % strings of restricted information variables
signresX_init=strngs1(max(rows)+1:end,min(clmns)-1); %strngs1 is already adjusted for empty rows and columns
% which information variables are restricted?
Xsignres=ismember(signresX_init,favar.informationvariablestrings);
% number of restricted variables in X
favar.nrelmagnresX=sum(Xsignres);
% keep only the ones that are actually in X
favar.relmagnresX=signresX_init(Xsignres==1,:);
if favar.nrelmagnresX==0
favar.relmagnresX_index=[];
end

% % all rows that are not empty
neclmns1index=neclmns1==1;
nerows1index=nerows1(neclmns1index,1);
% nerows1indexend=find(nerows1index==rows(end,1));
% if nerows1indexend==size(nerows1index,1)
%     favar.nrelmagnresX=0;
%     favar.relmagnresX_index=[];
% else
% % only information variables in X that are restricted
Xnerows1index=nerows1index(size(rows,1)+1:end,1);
% % strings of restricted information variables
% favar.relmagnresX=strngs1(max(rows)+1:end,min(clmns)-1); %strngs1 is already adjusted for empty rows and columns
% %number of restricted information variables
% favar.nrelmagnresX=size(favar.relmagnresX,1);
% end
%create indices for restricted information variables (advantage here: ordering in the sign res table is irrelevant)
    for jj=1:favar.nrelmagnresX
        for ii=1:favar.nfactorvar
        favar.relmagnresX_indexlogical{jj,1}(ii,1)=strcmp(favar.informationvariablestrings(1,ii),favar.relmagnresX{jj,1});
        end
    end
    for jj=1:favar.nrelmagnresX
        favar.relmagnresX_index(jj,1)=find(favar.relmagnresX_indexlogical{jj,1});
    end
    
favar.relmagnrestable=cell(favar.nrelmagnresX,n);   
% now recover the values for the cell favar.signrestable
for ii=1:favar.nrelmagnresX % loop over restricted information variables
   for jj=1:n % loop over endogenous (columns)
   favar.relmagnrestable{ii,jj}=strngs1{Xnerows1index(ii,1),clmns(jj,1)};
   end
end


 % identify empty relmagn res table columns
for ii=1:size(favar.relmagnrestable,2)
    strctident.favar_relmagnrestableempty(ii,1)=isempty(cat(2,favar.relmagnrestable{:,ii}))==1;
end


% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in sign res table
            if strctident.relmagnrestableempty(1,1)==0
                for ll=1:size(favar.relmagnrestable,1)
                favar.relmagnrestable{ll,1}='';
                end
                message=['The restrictions in the first column of the "relmagn res values" table are ignored. This is the IV shock.'];
                msgbox(message,'Relative magnitude restriction warning');
                
            end
end

%assuming that the variables in the table here are identical to the variables in the sign res value table
% now recover the values for the cell favar.signrestable
for ii=1:favar.nrelmagnresX % loop over restricted information variables
   for jj=1:n % loop over endogenous (columns)
   favar.relmagnresperiods{ii,jj}=str2num(strngs2{Xnerows1index(ii,1),clmns(jj,1)});
   end
end

% check if we have restrictions
if sum(strctident.favar_relmagnrestableempty==0)~=0
favar_temp=cell2mat(favar.relmagnresperiods(~cellfun(@isempty,favar.relmagnresperiods)));
favar_mperiods=[];
for ii=1:size(favar_temp,1)
favar_mperiods=[favar_mperiods favar_temp(ii,1):favar_temp(ii,2)];
end
% if (favar_mperiods/2)~=favar.nrelmagnresX
%       message=['The restrictions in the "relmagn res values" table do not correspond to the periods in "relmagn res periods".'];
%       msgbox(message,'Relative magnitude restriction warning');
%       error('programme termination: relative magnitude restriction error');
% end
% suppress duplicates and sort
strctident.favar_mperiods=sort(unique(favar_mperiods))';
% count the total number of restriction periods (required for IRF matrix)
%favar_rmperiods=size(strctident.favar_mperiods,1); %%%%periods or mperiods here?

%create matrix entry for relative magnitude restrictions
[r] = find(~cellfun('isempty',favar.relmagnrestable)); % why is clm not used?
%2. Indentify which entry corresponds to the positive magnitude
%restriction (which shock is supposed to have a larger impact on which
%variable)
favar_num_magres=length(r)/2; %number of relative magnitude restrictions

strctident.favar_rowsS=[];
strctident.favar_columnsS=[];
for jj=1:favar_num_magres %%loop over number of magnitude restrictions
favar_strtemp=strcat('S',num2str(jj)+num_magres); %+num_magres
Stronger=strcmp(favar.relmagnrestable,favar_strtemp);
[favar_rowS,favar_columnS]=find(Stronger==1);
strctident.favar_rowsS=[strctident.favar_rowsS favar_rowS];
strctident.favar_columnsS=[strctident.favar_columnsS favar_columnS];
end

strctident.favar_rowsW=[];
strctident.favar_columnsW=[];
for jj=1:favar_num_magres
favar_strtemp=strcat('W',num2str(jj)+num_magres); %+num_magres
Weaker=strcmp(favar.relmagnrestable,favar_strtemp);
[favar_rowW,favar_columnW]=find(Weaker==1);
strctident.favar_rowsW=[strctident.favar_rowsW favar_rowW];
strctident.favar_columnsW=[strctident.favar_columnsW favar_columnW];
end

% check number of W and S restrictions
if size(strctident.favar_columnsW,1)~=size(strctident.favar_columnsS,1)
    strctident.favar_relmagnres=0;
    strctident.hbartext_favar_relmagnres='';    
    message=['S and W restrictions (FAVAR) are inconsistent. Relative magnitude restrictions (FAVAR) are ignored.'];
    msgbox(message,'Relative magnitude restriction warning');
else
% check for relative magnitude restrictions
if isempty(strctident.favar_columnsW)==0 && isempty(strctident.favar_columnsS)==0
    strctident.favar_relmagnres=1;
    strctident.hbartext_favar_relmagnres='favar-rel. magnitude, ';
    
    % check if shocks are not identified via sign res or favar sign res,relmagn res, but via favar relmagn res
    % check for empty signres, favar_signres,relmagn res  and non-empty favar relmagn res shocks
for ii=1:size(strctident.signreslabels,1)
    if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==1 && strctident.favar_relmagnrestableempty(ii,1)==0
        % add them to the list of identified shocks in this case
        if isempty(strngs1{min(rows)-2,clmns(ii,1)})==0
        strctident.signreslabels{ii,1}=strngs1{min(rows)-2,clmns(ii,1)}; % take the label provided in the table in this case
        else
        strctident.signreslabels{ii,1}=['shock ' num2str(ii)];    % or generate a label
        end
        strctident.signreslabels_shocksindex=[strctident.signreslabels_shocksindex; ii]; % add it in the shocksindex
    end
end
% update the output in strctident
strctident.signreslabels_shocksindex=unique(strctident.signreslabels_shocksindex);
strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
signreslabels=strctident.signreslabels;

% create indices for plotXshock
if favar.IRF.plot==1 && favar.npltX>0
        IRFplotXshock_indexlogical=ismember(signreslabels,favar.IRF.pltXshck);
        favar.IRF.plotXshock_index=find(IRFplotXshock_indexlogical==1)';
        favar.IRF.npltXshck=size(favar.IRF.pltXshck,1);
        if favar.IRF.npltXshck==0
        % error if no shock to plot is found, otherwise code crashes at a later stage
        message=['Error: at least one Shock (' favar.IRF.plotXshock ') cannot be found.'];
        msgbox(message,'favar.IRF.npltXshck error');
        error('programme termination: favar.IRF.plotXshock error');
        end
end
if favar.FEVD.plot==1
        FEVDplotXshock_indexlogical=ismember(signreslabels,favar.FEVD.pltXshck);
        favar.FEVD.plotXshock_index=find(FEVDplotXshock_indexlogical==1)';
        favar.FEVD.npltXshck=size(favar.FEVD.pltXshck,1);
end

% adjust periods in case the maximum number of restricted periods is larger for favar restrictions only
if max(strctident.favar_mperiods)>max(strctident.mperiods)
    strctident.mperiods=strctident.favar_mperiods;
end


elseif isempty(strctident.columnsW)==1 && isempty(strctident.columnsS)==1
    strctident.favar_relmagnres=0;
    strctident.hbartext_favar_relmagnres='';
end
end

else % when no rel. mag res are found here
strctident.favar_relmagnres=0;
strctident.hbartext_favar_relmagnres='';
end


else %no favar
    strctident.favar_relmagnres=0;
    strctident.hbartext_favar_relmagnres='';
    strctident.favar_relmagnrestableempty=ones(n,1);
end


% finally, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs1,'relmagn res values','B2');
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs2,'relmagn res periods','B2');
end
end 
