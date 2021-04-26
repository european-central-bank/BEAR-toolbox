function [blockexo]=loadbex(endo,pref)










% preliminary tasks

% identify the number of endogenous variables
numendo=size(endo,1);
% initiate the matrix blockexo
blockexo=zeros(numendo,numendo);
% load the data from Excel
[num txt strngs]=xlsread('data.xlsx','block exo');
% replace NaN entries by blanks
strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
% convert all numeric entries into strings
strngs(cellfun(@isnumeric,strngs))=cellfun(@num2str,strngs(cellfun(@isnumeric,strngs)),'UniformOutput',0);
% identify the non-empty entries (pairs of rows and columns)
[nerows neclmns]=find(~cellfun('isempty',strngs));
% count the number of such entries
neentries=size(nerows,1);
% all these entries contrain strings: fix them to correct potential user formatting errors
% loop over entries
for ii=1:neentries
strngs{nerows(ii,1),neclmns(ii,1)}=fixstring(strngs{nerows(ii,1),neclmns(ii,1)});
end


% recover the rows and columns of each endogenous variable

% loop over endogenous variables
for ii=1:numendo
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[r,c]=find(strcmp(strngs,endo{ii,1}));
   % if it is not possible to find two entries, return an error
   if size(r,1)<2
   message=['Block exogeneity error: endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''block exo'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: block exogeneity error');   
   end
% otherwise, the greatest number in r corresponds to the row of the column labels: record it
rows(ii,1)=max(r);
% the greatest number in c corresponds to the column of the row labels: record it
clmns(ii,1)=max(c);
end



% now recover the matrix values

% loop over endogenous (rows)
for ii=1:numendo
   % loop over endogenous (columns)
   for jj=1:numendo
   temp=strngs{rows(ii,1),clmns(jj,1)};
      % if the entry is a 1 (as a string), there is a restriction: switch the corresponding blockexo entry to 1
      if strcmp(temp,'1')
      blockexo(ii,jj)=1;   
      % else, if there is no restriction, ignore
      end
   end
end

% Transpose to make it comparable to IRF plots
blockexo = blockexo';

% finally, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs,'block exogeneity','B2');
end




