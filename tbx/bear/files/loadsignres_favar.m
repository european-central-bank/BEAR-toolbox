function [favar]=loadsignres_favar(pref,favar,endo)

%%%%% Routine for information variables X
% preliminary tasks
% identify the number of endo
favar.numendo=size(endo,1);

% initiate the cells signrestable, signresperiods and signreslabels %%%% I think this step is not necessary
% favar.signrestable=cell(favar.nsignres,favar.numendo); %number of information variables to be restricted, one for the moment
% favar.signresperiods=cell(favar.nsignres,favar.numendo); %number of information variables to be restricted, one for the moment
% favar.signreslabels=favar.informationvariablestrings{1,1}; %number of information variables to be restricted, one for the moment
% load the data from Excel
% sign restrictions values
[~,~,strngs1]=xlsread('data.xlsx','favar.sign res values');
[~,~,strngs2]=xlsread('data.xlsx','favar.sign res periods');
% replace NaN entries by blanks
strngs1(cellfun(@(x) any(isnan(x)),strngs1))={[]};
strngs2(cellfun(@(x) any(isnan(x)),strngs2))={[]};
% convert all numeric entries into strings
strngs1(cellfun(@isnumeric,strngs1))=cellfun(@num2str,strngs1(cellfun(@isnumeric,strngs1)),'UniformOutput',0);
strngs2(cellfun(@isnumeric,strngs2))=cellfun(@num2str,strngs2(cellfun(@isnumeric,strngs2)),'UniformOutput',0);
% identify the non-empty entries (pairs of rows and columns)
[nerows1,neclmns1]=find(~cellfun('isempty',strngs1));
[nerows2,neclmns2]=find(~cellfun('isempty',strngs2));
% count the number of such entries
neentries1=size(nerows1,1);
neentries2=size(nerows2,1);
% all these entries contrain strings: fix them to correct potential user formatting errors
% loop over entries (value table)
for ii=1:neentries1
strngs1{nerows1(ii,1),neclmns1(ii,1)}=fixstring(strngs1{nerows1(ii,1),neclmns1(ii,1)});
end
% loop over entries (period table)
for ii=1:neentries2
strngs2{nerows2(ii,1),neclmns2(ii,1)}=fixstring(strngs2{nerows2(ii,1),neclmns2(ii,1)});
end

% information variables in X that are restricted
neclmns1index=neclmns1==1;
nerows1index=nerows1(neclmns1index,1);

favar.signresX=strngs1(nerows1index,1);
%number of restricted information variables
favar.nsignresX=size(favar.signresX,1);

%create indices for restricted information variables (advantage here: ordering in the sign res table is irrelevant)
    for jj=1:favar.nsignresX
        for ii=1:favar.nfactorvar
        favar.signresX_indexlogical{jj,1}(ii,1)=strcmp(favar.informationvariablestrings(1,ii),favar.signresX{jj,1}); % do we need this output in favar.?
        end
    end
    for jj=1:favar.nsignresX
        favar.signresX_index(jj,1)=find(favar.signresX_indexlogical{jj,1}==1);
    end


% sign restriction values

% loop over endogenous variables
for ii=1:favar.numendo
    [~,c]=find(strcmp(strngs1,endo{ii,1}));
for ll=1:favar.nsignresX
[r,~]=find(strcmp(favar.signresX,favar.informationvariablestrings{ll,1}));% first entry number of information variables to be restricted, one for the moment
   % if it is not possible to find two entries, return an error
%    if size(r,1)<2
%    message=['favar Sign restriction error: information variable ' favar.informationvariablestrings{ll,1} ' cannot be found in both rows and columns of the table. Please verify that the ''sign res values'' sheet of the Excel data file is properly filled.'];
%    msgbox(message);
%    error('programme termination: sign restriction error');   
%    end
% otherwise, the greatest number in r corresponds to the row of the column labels: record it
rows(favar.nsignresX,1)=max(r);
% the greatest number in c corresponds to the column of the row labels: record it
clmns(ii,1)=max(c);
end
end
% now recover the values for the cell signrestable
% loop over endogenous (rows)
for ii=1:favar.nsignresX % loop over restricted information variables
   for jj=1:favar.numendo % loop over endogenous (columns)
   favar.signrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
   end
end
%favar sign res table can be integrated to the normal one. take the
%signrestable definition (endpoints) from the normal one, and just start
%the favar table after that

% check whether the restriction table is valid: return an error if the the column requirement for zero restrictions is not satisfied
% loop over columns
for ii=1:favar.numendo
% count the number of zero restrictions in this column
numzerores=sum(strcmp(favar.signrestable(:,ii),'0'));
   % if there are too many zero restrictions for the column, return an error
   if numzerores>favar.numendo-ii
   temp=['Zero restriction issue: you have requested ' num2str(numzerores) ' zero restrictions in column ' num2str(ii) ' of the restriction matrix, but at most ' num2str(favar.numendo-ii) ' such restrictions can be implemented.'];
   msgbox(temp);
   error('Zero restriction error');
   end
end


% sign restriction periods

% recover the rows and columns of each endogenous variable
% loop over endogenous variables
for ii=1:favar.numendo
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[~,c]=find(strcmp(strngs1,endo{ii,1}));
[r,~]=find(strcmp(strngs1,favar.informationvariablestrings{ll,1}));% first entry number of information variables to be restricted, one for the moment
   % if it is not possible to find two entries, return an error
%    if size(r,1)<2
%    message=['Sign restriction error: endogenous variable ' favar.informationvariablestrings{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''sign res periods'' sheet of the Excel data file is properly filled.'];
%    msgbox(message);
%    error('programme termination: sign restriction error');   
%    end
% the greatest number in r corresponds to the row of the column labels: record it
rows(favar.nsignresX,1)=max(r);
% the greatest number in c corresponds to the column of the row labels: record it
clmns(ii,1)=max(c);
end
% now recover the values for the cell signresperiods
% loop over endogenous (rows)
for ii=1:1 %number of information variables to be restricted, one for the moment
   % loop over endogenous (columns)
   for jj=1:favar.numendo
   % record the value
   favar.signresperiods{ii,jj}=str2num(strngs2{rows(ii,1),clmns(jj,1)});
   end
end

% recover the labels, if any
% initiate
favar.signreslabels=cell(favar.numendo,1);
% loop over endogenous (columns)
for ii=1:favar.numendo
% the label for shock ii is found in strngs2, row 3 and column 'clmns(ii,1)'
temp=strngs2{1,clmns(ii,1)};
   % if empty, give the generic name 'shock ii'
   if isempty(temp)
   favar.signreslabels{ii,1}=['shock ' num2str(ii)];
   % else, record the name
   else
   favar.signreslabels{ii,1}=temp;
   end
end

% finally, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs1,'favar.sign res values','B2');
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs2,'favar.sign res periods','B2');
end
