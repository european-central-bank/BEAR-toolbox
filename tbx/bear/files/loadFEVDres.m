function [FEVDrestable,FEVDresperiods,signreslabels,strctident,favar]=loadFEVDres(n,endo,pref,favar,IRFt,strctident)


% preliminary tasks

% initiate the cells FEVDrestable and FEVDresperiods
FEVDrestable=cell(n,n);
FEVDresperiods=cell(n,n);
signreslabels=strctident.signreslabels;
signreslabels_shocksindex=strctident.signreslabels_shocksindex;
% load the data from Excel
% sign restrictions values
[~,~,strngs1]=xlsread('data.xlsx','FEVD res values');
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


%% check if FEVD restrictions are activated at all
for ii=1:n % loop over endogenous variables
% one is the column label, the other is the row label
[r,c]=find(strcmp(strngs1,endo{ii,1}));
if ~isempty(r)
rows(ii,1)=max(r);
% the greatest number in c corresponds to the column of the row labels: record it
clmns(ii,1)=max(c);
else
rows(ii,1)=0;
clmns(ii,1)=0;
end
end

% now recover the values for the cell FEVDrestable
for ii=1:n % loop over endogenous (rows)
   for jj=1:n % loop over endogenous (columns)
       if rows(ii,1)~=0 && clmns(jj,1)~=0
            FEVDrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
       end
    end
end

% check for empty columns in FEVDrestable
count=0;
for ii=1:size(FEVDrestable,2)
    FEVDrestablecat=cat(2,FEVDrestable{:,ii});
     if isempty(FEVDrestablecat)==0
        count=count+1;
    end
end

if count==0 && favar.FAVAR==0 % we found no FEVDres (this test is not applicable to the favar restrictions)
    strctident.FEVDres=0;
    strctident.hbartext_FEVDres='';
    strctident.favar_FEVDres=0;
    strctident.hbartext_favar_FEVDres='';
    strctident.FEVDrestableempty=ones(n,1);
    strctident.favar_FEVDrestableempty=ones(n,1);
else % if we found something in the table then the FEVD res routine is activated
    FEVDrestable=cell(n,n);
    clear FEVDrestablecat
%% FEVD restriction values
for ii=1:n % loop over endogenous variables
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[r,c]=find(strcmp(strngs1,endo{ii,1}));
   % if it is not possible to find two entries, return an error
   if size(r,1)<2
   message=['Endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''FEVD res values'' sheet of the Excel data file is properly filled.'];
   msgbox(message,'FEVD restriction error');
   error('programme termination: FEVD restriction error');   
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
   FEVDrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
   end
end


 % identify empty FEVD res table columns
for ii=1:size(FEVDrestable,2)
    strctident.FEVDrestableempty(ii,1)=isempty(cat(2,FEVDrestable{:,ii}))==1;
end

% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in FEVD res table
            if strctident.FEVDrestableempty(1,1)==0
                for ll=1:size(FEVDrestable,1)
                FEVDrestable{ll,1}='';
                end
                signreslabels{1,1}=strcat('IV Shock (',strctident.Instrument,')');
                signreslabels_shocksindex(1,1)=1;
                message=['The restrictions in the first column of the "FEVD res values" table are ignored. This is the IV shock.'];
                msgbox(message,'FEVD restriction warning');
            end
end


% FEVD restriction periods
[~,~,strngs2]=xlsread('data.xlsx','FEVD res periods');
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
   message=['FEVD restriction error: endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''FEVD res periods'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: FEVD restriction error');   
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
   FEVDresperiods{ii,jj}=str2num(strngs2{rows2(ii,1),clmns2(jj,1)});
   end
end

% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in sign res table
        for ii=1:size(FEVDresperiods,2)
            FEVDresperiodscat=cat(2,FEVDresperiods{:,ii});
            if ii==1 && isempty(FEVDresperiodscat)==0
                for ll=1:size(FEVDresperiods,1)
                FEVDresperiods{ll,ii}='';
                end
                message=['The restrictions in the first column of the "FEVD res periods" table are ignored. This is the IV shock.'];
                msgbox(message,'FEVD restriction warning');
            end
        end
end


% however if we have no sign, relmagn restrictions at all, but we have FEVD restrictions then generate them from the "FEVD res values" table
if strctident.signres==0 && strctident.zerores==0 && strctident.magnres==0 && strctident.favar_signres==0 && strctident.favar_zerores==0 && strctident.favar_magnres==0 && strctident.relmagnres==0 && strctident.favar_relmagnres==0   
    
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
           if strctident.FEVDrestableempty(ii)==0 % restrictions, however no label is found, count this column
           signreslabels_shocksindex=[signreslabels_shocksindex; ii];
           end
       end
   % else, record the name
   else
       if IRFt==6 && ii==1 % special case for the IV shock in IRFt==6
       signreslabels{ii,1}=strcat('IV Shock (',strctident.Instrument,')');
       signreslabels_shocksindex=[signreslabels_shocksindex; ii];
       else
       if strctident.FEVDrestableempty(ii)==0 % label and restictions found
            signreslabels{ii,1}=temp;
            signreslabels_shocksindex=[signreslabels_shocksindex; ii];
       elseif strctident.FEVDrestableempty(ii)==1 % label, however no restriction is found, ignore this column
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


%% Preliminaries for FEVD restriction
% now identify all the periods concerned with FEVD restrictions
% first expand the non-empty entries in FEVDresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4]; 
temp=cell2mat(FEVDresperiods(~cellfun(@isempty,FEVDresperiods)));
FEVDperiods=[];
for ii=1:size(temp,1)
    FEVDperiods=[FEVDperiods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
strctident.FEVDperiods=sort(unique(FEVDperiods))';

%create matrix entry for relative magnitude restrictions
[rowsFEVD,clmFEVD] = find(~cellfun('isempty',FEVDrestable));
num_FEVDres=length(rowsFEVD); %number of FEVD restrictions
strctident.rowsFEVD=rowsFEVD; %save in strctident

%check if rows are unique. Two FEVD restrictions for one variable are not
%included in the algorithm. Two columns (shocks) are fine.
uniquerows = unique(rowsFEVD);

if length(uniquerows) < length(rowsFEVD)
    error('Two FEVD restrictions for one variable are not permitted')
end

% now identify if the FEVD restrictions are absolute ones or relative ones
%first for Relative restrictions
rowrelativeFEVD=zeros(num_FEVDres,1);
clmrelativeFEVD=zeros(num_FEVDres,1);
in=[];
for jj=1:num_FEVDres
    if strcmp(FEVDrestable{rowsFEVD(jj,1),clmFEVD(jj,1)},'Relative')==1
        in=[in,jj];
        rowrelativeFEVD(jj,1)=rowsFEVD(jj,1); %rows are the variables for the FEVD
        clmrelativeFEVD(jj,1)=clmFEVD(jj,1);%Columns are the variables for the FEVD
    end
end
%keep only entries that are Relative restrictions and save in strctident
strctident.rowrelativeFEVD=rowrelativeFEVD(in,1);
strctident.clmrelativeFEVD=clmrelativeFEVD(in,1);

%now the same for Absolute restrictions
rowabsoluteFEVD=zeros(num_FEVDres,1);
clmabsoluteFEVD=zeros(num_FEVDres,1);
in=[];
for jj=1:num_FEVDres
    if strcmp(FEVDrestable{rowsFEVD(jj,1),clmFEVD(jj,1)},'Absolute')==1
        in=[in,jj];
        rowabsoluteFEVD(jj,1)=rowsFEVD(jj,1);%rows are the variables for the FEVD
        clmabsoluteFEVD(jj,1)=clmFEVD(jj,1); %Columns are the variables for the FEVD
    end
end
%keep only entries that are Absolute restrictions and save in strctident
strctident.rowabsoluteFEVD=rowabsoluteFEVD(in,1);
strctident.clmabsoluteFEVD=clmabsoluteFEVD(in,1);


% check for FEVD restrictions
if size(strctident.clmabsoluteFEVD,1)==0 && size(strctident.clmrelativeFEVD,1)==0 %when there are no absolute and no relative FEVD restrictions
    strctident.FEVDres=0;
    strctident.hbartext_FEVDres='';
elseif isempty(strctident.FEVDperiods)==1
    strctident.FEVDres=0;
    strctident.hbartext_FEVDres='';
    message=['"FEVD res periods" is empty. FEVD restrcitions are ignored.'];
    msgbox(message,'FEVD restriction warning');
else
    strctident.FEVDres=1;
    strctident.hbartext_FEVDres='FEVD, ';
    % check if shocks are not identified via sign res, but via FEVD res only
    % identify empty FEVD res table columns

% check for empty sign res and non-empty FEVD res shocks
for ii=1:size(strctident.signreslabels,1)
    if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==1 && strctident.favar_relmagnrestableempty(ii,1)==1 && strctident.FEVDrestableempty(ii,1)==0
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
strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
signreslabels=strctident.signreslabels;

end

%% FAVAR FEVD
if favar.FAVAR==1

% all rows that are not empty
neclmns1index=neclmns1==1;
nerows1index=nerows1(neclmns1index,1);
% only information variables in X that are restricted
Xnerows1index=nerows1index(size(rows,1)+1:end,1);

% strings of restricted information variables
signresX_init=strngs1(max(rows)+1:end,min(clmns)-1); %strngs1 is already adjusted for empty rows and columns
% which information variables are restricted?
Xsignres=ismember(signresX_init,favar.informationvariablestrings);
% number of restricted variables in X
favar.nFEVDresX=sum(Xsignres);
% keep only the ones that are actually in X
favar.FEVDresX=signresX_init(Xsignres==1,:);


if favar.nFEVDresX~=0
%create indices for restricted information variables (advantage here: ordering in the sign res table is irrelevant)
    for jj=1:size(favar.FEVDresX,1)
        for ii=1:favar.nfactorvar
        favar.FEVDresX_indexlogical{jj,1}(ii,1)=strcmp(favar.informationvariablestrings(1,ii),favar.FEVDresX{jj,1});
        end
    end
    for jj=1:size(favar.FEVDresX,1)
        favar.FEVDresX_index(jj,1)=find(favar.FEVDresX_indexlogical{jj,1},1);
    end
% now recover the values for the cell favar.signrestable
for ii=1:size(favar.FEVDresX,1) % loop over restricted information variables
   for jj=1:n % loop over endogenous (columns)
   favar.FEVDrestable{ii,jj}=strngs1{Xnerows1index(ii,1),clmns(jj,1)};
   end
end

 % identify empty relmagn res table columns
for ii=1:size(favar.FEVDrestable,2)
    strctident.favar_FEVDrestableempty(ii,1)=isempty(cat(2,favar.FEVDrestable{:,ii}))==1;
end


% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in sign res table
            if strctident.favar_FEVDrestableempty(1,1)==0
                for ll=1:size(favar.FEVDrestable,1)
                favar.FEVDrestable{ll,1}='';
                end
                message=['The restrictions in the first column of the "FEVD res values" table are ignored. This is the IV shock.'];
                msgbox(message,'FEVD restriction warning (FAVAR)');
            end
end

%assuming that the variables in the table here are identical to the variables in the sign res value table
% now recover the values for the cell favar.signrestable
for ii=1:size(favar.FEVDresX,1) % loop over restricted information variables
   for jj=1:n % loop over endogenous (columns)
   strctident.favar_FEVDresperiods{ii,jj}=str2num(strngs2{Xnerows1index(ii,1),clmns(jj,1)});
   end
end


% erase first column in the restriction table for IV shock
if IRFt==6
        % check for empty columns in sign res table
        for ii=1:size(strctident.favar_FEVDresperiods,2)
            favar_FEVDresperiodscat=cat(2,strctident.favar_FEVDresperiods{:,ii});
            if ii==1 && isempty(favar_FEVDresperiodscat)==0
                for ll=1:size(strctident.favar_FEVDresperiods,1)
                strctident.favar_FEVDresperiods{ll,ii}='';
                end
                message=['The restrictions in the first column of the "FEVD res periods" table are ignored. This is the IV shock.'];
                msgbox(message,'FEVD restriction warning (FAVAR)');
            end
        end
end


% Preliminaries for FEVD restriction (FAVAR)
% now identify all the periods concerned with FEVD restrictions
% first expand the non-empty entries in FEVDresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4]; 
temp=cell2mat(strctident.favar_FEVDresperiods(~cellfun(@isempty,strctident.favar_FEVDresperiods)));
favar_FEVDperiods=[];
for ii=1:size(temp,1)
    favar_FEVDperiods=[favar_FEVDperiods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
strctident.favar_FEVDperiods=sort(unique(favar_FEVDperiods))';

%create matrix entry for relative magnitude restrictions
[favar_rowsFEVD,favar_clmFEVD] = find(~cellfun('isempty',favar.FEVDrestable));
strctident.favar_rowsFEVD=favar_rowsFEVD;% save in strctident
favar_num_FEVDres=length(favar_rowsFEVD); %number of FEVD restrictions
%number of restricted information variables
favar.nFEVDresX=favar_num_FEVDres;

%check if rows are unique. Two FEVD restrictions for one variable are not
%included in the algorithm. Two columns (shocks) are fine.
favar_uniquerows = unique(favar_rowsFEVD);

if length(favar_uniquerows) < length(favar_rowsFEVD)
    error('Two FEVD restrictions (FAVAR) for one variable are not permitted.')
end

%now identify if the FEVD restrictions are absolute ones or relative ones
%first for Relative restrictions
favar_numrelativeFEVD=0;
favar_rowrelativeFEVD=zeros(favar_num_FEVDres,1);
favar_clmrelativeFEVD=zeros(favar_num_FEVDres,1);
in=[];
for jj=1:favar_num_FEVDres
    if strcmp(favar.FEVDrestable{favar_rowsFEVD(jj,1),favar_clmFEVD(jj,1)},'Relative')==1
        favar_numrelativeFEVD=favar_numrelativeFEVD+1;
        in=[in,jj];
        favar_rowrelativeFEVD(jj,1)=favar_rowsFEVD(jj,1); %rows are the variables for the FEVD
        favar_clmrelativeFEVD(jj,1)=favar_clmFEVD(jj,1);%Columns are the variables for the FEVD
    end
end
%keep only entries that are Relative restrictions and save in strctident
strctident.favar_rowrelativeFEVD=favar_rowrelativeFEVD(in,1);
strctident.favar_clmrelativeFEVD=favar_clmrelativeFEVD(in,1);


%now the same for Absolute restrictions
favar_numabsoluteFEVD=0;
favar_rowabsoluteFEVD=zeros(favar_num_FEVDres,1);
favar_clmabsoluteFEVD=zeros(favar_num_FEVDres,1);
in=[];
for jj=1:favar_num_FEVDres
    if strcmp(favar.FEVDrestable{favar_rowsFEVD(jj,1),favar_clmFEVD(jj,1)},'Absolute')==1
        favar_numabsoluteFEVD=favar_numabsoluteFEVD+1;
        in=[in,jj];
        favar_rowabsoluteFEVD(jj,1)=favar_rowsFEVD(jj,1);%rows are the variables for the FEVD
        favar_clmabsoluteFEVD(jj,1)=favar_clmFEVD(jj,1); %Columns are the variables for the FEVD    
    end
end
%keep only entries that are Absolute restrictions and save in strctident
strctident.favar_rowabsoluteFEVD=favar_rowabsoluteFEVD(in,1);
strctident.favar_clmabsoluteFEVD=favar_clmabsoluteFEVD(in,1);

% save the relevant indices only:
relevantRows=[nonzeros(strctident.favar_rowrelativeFEVD) nonzeros(strctident.favar_rowabsoluteFEVD)];
favar.FEVDresX_index=favar.FEVDresX_index(relevantRows,1);



% check for FEVD restrictions
if favar_numabsoluteFEVD ==0 && favar_numrelativeFEVD==0 %when there are no absolute and no relative FEVD restrictions
%     message=['Please verify that the ''FEVD res values'' sheet of the Excel data file is properly filled. FEVD restrictions (FAVAR) are ignored.'];
%     msgbox(message,'Relative magnitude restriction warning');
    strctident.favar_FEVDres=0;
    strctident.hbartext_favar_FEVDres='';
else
    strctident.favar_FEVDres=1;
    strctident.hbartext_favar_FEVDres='favar-FEVD, ';
    
        % check if shocks are not identified via sign res or favar sign res,relmagn res, but via favar relmagn res
    % check for empty signres, favar_signres,relmagn res  and non-empty favar relmagn res shocks
for ii=1:size(strctident.signreslabels,1)
    if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==1 && strctident.favar_relmagnrestableempty(ii,1)==1 && strctident.FEVDrestableempty(ii,1)==1 && strctident.favar_FEVDrestableempty(ii,1)==0
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
% if favar.FEVD.plot==1
%         FEVDplotXshock_indexlogical=ismember(signreslabels,favar.FEVD.pltXshck);
%         favar.FEVD.plotXshock_index=find(FEVDplotXshock_indexlogical==1)';
%         favar.FEVD.npltXshck=size(favar.FEVD.pltXshck,1);
% end

end


else % when no FEVD res are found here
    strctident.favar_FEVDres=0;
    strctident.hbartext_favar_FEVDres='';
    strctident.favar_FEVDrestableempty=ones(n,1);
    favar.FEVDresX_index=[];
end


else % if favar is off
    strctident.favar_FEVDres=0;
    strctident.hbartext_favar_FEVDres='';
    strctident.favar_FEVDrestableempty=ones(n,1);
end



% finally, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs1,'FEVD res values','B2');
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs2,'FEVD res periods','B2');
end
end