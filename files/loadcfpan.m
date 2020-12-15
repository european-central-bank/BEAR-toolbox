function [cfconds cfshocks cfblocks]=loadcfpan(endo,Units,panel,CFt,Fstartdate,Fenddate,Fperiods,pref)




















% identify the number of endogenous variables
numendo=size(endo,1);
% identify the number of units
numunits=size(Units,1);
% initiate the cells
cfconds={};
cfshocks={};
cfblocks=[];





% recover the cfconds cell (for all types of conditional forecasts)

% load the data from Excel
[num txt strngs]=xlsread('data.xlsx','pan conditions');
% replace NaN entries by blanks
strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
% convert potential numeric entries into strings
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
% identify the rows coresponding respectively to the forecast start date and forecast end dates
temp=find(strcmp(strngs,Fstartdate));
   % if empty, return an error
   if isempty(temp)
   message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''pan conditions'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: conditional forecast error'); 
   end
% otherwise, record
rows(1,1)=temp;  
temp=find(strcmp(strngs,Fenddate));
   % if empty, return an error
   if isempty(temp)
   message=['conditional forecast error: forecast end date ' Fenddate ' cannot be found. Please verify that the ''pan conditions'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: conditional forecast error'); 
   end
% otherwise, record
rows(2,1)=temp; 





% now the treatment will differ according to the type of panel VAR model

% if the model is panel 2,3 or 4, different conditional forecasts will be estimated for each unit
% then cfconds becomes a cell with a number of pages equivalent to the number of units
if panel==2 || panel==3 || panel==4
% create the cell cfconds
cfconds=cell(Fperiods,numendo,numunits);
   % loop over units
   for ii=1:numunits
      % loop over endogenous
      for jj=1:numendo
      % find the column corresponding to the combination unit_variable
      [~,clmns]=find(strcmp(strngs,[Units{ii,1} '_' endo{jj,1}]));
         % if the string cannot be found, return an error
         if isempty(clmns)
         message=['conditional forecast error: endogenous variable ' endo{jj,1} ' cannot be found for unit ' Units{ii,1} '. Please verify that the ''pan conditions'' sheet of the Excel data file is properly filled.'];
         msgbox(message);
         error('programme termination: conditional forecast error');    
         end
         % else, loop over forecast periods
         for kk=1:Fperiods
         % fill the corresponding entry
         cfconds{kk,jj,ii}=str2num(strngs{rows(1,1)+kk-1,clmns});
         end
      end
   end
   
   
   
   
   
% if the model is panel 5 or 6, a single model is estimated with all units, hence cfconds contains only one page
elseif panel==5 || panel==6
% create the cell cfconds
cfconds=cell(Fperiods,numendo*numunits);
% initiate the column count
clmncount=0;
   % loop over units
   for ii=1:numunits
      % loop over endogenous
      for jj=1:numendo
      % increment column count
      clmncount=clmncount+1;
      % find the column corresponding to the combination unit_variable
      [~,clmns]=find(strcmp(strngs,[Units{ii,1} '_' endo{jj,1}]));
         % if the string cannot be found, return an error
         if isempty(clmns)
         message=['conditional forecast error: endogenous variable ' endo{jj,1} ' cannot be found for unit ' Units{ii,1} '. Please verify that the ''pan conditions'' sheet of the Excel data file is properly filled.'];
         msgbox(message);
         error('programme termination: conditional forecast error');    
         end
         % else, loop over forecast periods
         for kk=1:Fperiods
         % fill the corresponding entry
         cfconds{kk,clmncount}=str2num(strngs{rows(1,1)+kk-1,clmns});
         end
      end
   end
end
% if no error is returned, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs,'cf conditions','B2');
end




% recover the cfshocks cell (for shock-specific conditional forecasts only)

if CFt==2
% load the data from Excel
[num txt strngs]=xlsread('data.xlsx','pan shocks');
% replace NaN entries by blanks
strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
% convert potential numeric entries into strings
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
% identify the rows coresponding respectively to the forecast start date and forecast end dates
temp=find(strcmp(strngs,Fstartdate));
   % if empty, return an error
   if isempty(temp)
   message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''pan shocks'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: conditional forecast error'); 
   end
% otherwise, record
rows(1,1)=temp;  
temp=find(strcmp(strngs,Fenddate));
   % if empty, return an error
   if isempty(temp)
   message=['conditional forecast error: forecast end date ' Fenddate ' cannot be found. Please verify that the ''pan shocks'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: conditional forecast error'); 
   end
% otherwise, record
rows(2,1)=temp;





% now the treatment will differ according to the type of panel VAR model

   % if the model is panel 2,3 or 4, different conditional forecasts will be estimated for each unit
   % then cfshocks becomes a cell with a number of pages equivalent to the number of units
   if panel==2 || panel==3 || panel==4
   % create the cell cfshocks
   cfshocks=cell(Fperiods,numendo,numunits);
      % loop over units
      for ii=1:numunits
         % loop over endogenous
         for jj=1:numendo
         % find the column corresponding to the combination unit_variable
         [~,clmns]=find(strcmp(strngs,[Units{ii,1} '_' endo{jj,1}]));
            % if the string cannot be found, return an error
            if isempty(clmns)
            message=['conditional forecast error: endogenous variable ' endo{jj,1} ' cannot be found for unit ' Units{ii,1} '. Please verify that the ''pan shocks'' sheet of the Excel data file is properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error');    
            end
            % else, loop over forecast periods
            for kk=1:Fperiods
            % fill the corresponding entry
            cfshocks{kk,jj,ii}=str2num(strngs{rows(1,1)+kk-1,clmns});
            end
         end
      end
      
      
      
      
      
   % if the model is panel 5 or 6, a single model is estimated with all units, hence cfshocks contains only one page
   elseif panel==5 || panel==6
   % create the cell cfshocks
   cfshocks=cell(Fperiods,numendo*numunits);
   % initiate the column count
   clmncount=0;
      % loop over units
      for ii=1:numunits
         % loop over endogenous
         for jj=1:numendo
         % increment column count
         clmncount=clmncount+1;
         % find the column corresponding to the combination unit_variable
         [~,clmns]=find(strcmp(strngs,[Units{ii,1} '_' endo{jj,1}]));
            % if the string cannot be found, return an error
            if isempty(clmns)
            message=['conditional forecast error: endogenous variable ' endo{jj,1} ' cannot be found for unit ' Units{ii,1} '. Please verify that the ''pan shocks'' sheet of the Excel data file is properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error');    
            end
            % loop over forecast periods
            for kk=1:Fperiods
            % fill the corresponding entry
            cfshocks{kk,clmncount}=str2num(strngs{rows(1,1)+kk-1,clmns});
            end
         end
      end
   end
   
% if no error is returned, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs,'cf shocks','B2');
end
end





% recover the cfblocks matrix (for shock-specific conditional forecasts only)

if CFt==2
% load the data from Excel
[num txt strngs]=xlsread('data.xlsx','pan blocks');
% replace NaN entries by blanks
strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
% convert potential numeric entries into strings
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
% identify the rows coresponding respectively to the forecast start date and forecast end dates
% identify the rows coresponding respectively to the forecast start date and forecast end dates
temp=find(strcmp(strngs,Fstartdate));
   % if empty, return an error
   if isempty(temp)
   message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''pan shocks'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: conditional forecast error'); 
   end
% otherwise, record
rows(1,1)=temp;  
temp=find(strcmp(strngs,Fenddate));
   % if empty, return an error
   if isempty(temp)
   message=['conditional forecast error: forecast end date ' Fenddate ' cannot be found. Please verify that the ''pan shocks'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: conditional forecast error'); 
   end
% otherwise, record
rows(2,1)=temp;





% now the treatment will differ according to the type of panel VAR model
   % if the model is panel 2,3 or 4, different conditional forecasts will be estimated for each unit
   % then cfblocks becomes a matrix with a number of pages equivalent to the number of units
   if panel==2 || panel==3 || panel==4
   % create the matrix cfshocks
   cfblocks=zeros(Fperiods,numendo,numunits);
      % loop over units
      for ii=1:numunits
         % loop over endogenous
         for jj=1:numendo
         % find the column corresponding to the combination unit_variable
         [~,clmns]=find(strcmp(strngs,[Units{ii,1} '_' endo{jj,1}]));
            % if the string cannot be found, return an error
            if isempty(clmns)
            message=['conditional forecast error: endogenous variable ' endo{jj,1} ' cannot be found for unit ' Units{ii,1} '. Please verify that the ''pan blocks'' sheet of the Excel data file is properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error');    
            end
            % else, loop over forecast periods
            for kk=1:Fperiods
            % recover the entry
            temp=str2num(strngs{rows(1,1)+kk-1,clmns});
               % if the entry is empty, ignore
               if isempty(temp)
               % if not empty, record in cfblocks
               else
               cfblocks(kk,jj,ii)=temp;
               end
            end
         end
      end
      
      
      
      
      
   % if the model is panel 5 or 6, a single model is estimated with all units, hence cfblocks contains only one page
   elseif panel==5 || panel==6
   % create the cell cfblocks
   cfblocks=zeros(Fperiods,numendo*numunits);
   % initiate the column count
   clmncount=0;
      % loop over units
      for ii=1:numunits
         % loop over endogenous
         for jj=1:numendo
         % increment column count
         clmncount=clmncount+1;
         % find the column corresponding to the combination unit_variable
         [~,clmns]=find(strcmp(strngs,[Units{ii,1} '_' endo{jj,1}]));
            % if the string cannot be found, return an error
            if isempty(clmns)
            message=['conditional forecast error: endogenous variable ' endo{jj,1} ' cannot be found for unit ' Units{ii,1} '. Please verify that the ''pan blocks'' sheet of the Excel data file is properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error');    
            end
            % else, loop over forecast periods
            for kk=1:Fperiods
            % recover the entry
            temp=str2num(strngs{rows(1,1)+kk-1,clmns});
            % if the entry is empty, ignore
               if isempty(temp)
               % if not empty, record in cfblocks
               else
               cfblocks(kk,clmncount)=temp;
               end
            end
         end
      end
   end
   
% if no error is returned, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs,'cf blocks','B2');
end
end





% final verification: check that cfconds is consistent with the other cells/matrices (i.e. cfshocks and cfblocks)
% the way this is done depends on the panel model
% if the panel model is 2, 3 or 4
if panel==2 || panel==3 || panel==4
   % if the type of conditional forecasts is shock-specific
   if CFt==2
      % loop over units
      for ii=1:numunits
      % check if there are conditions on unit ii
      temp1=cfconds(:,:,ii);
      nconds(ii,1)=numel(temp1(cellfun(@(x) any(~isempty(x)),temp1)));    
         % if there are no conditions, ignore as there is nothing to check
         if nconds==0
         % if there are conditions
         else
         % identify the non-empty elements in cfconds
         [nerows1 neclmns1]=find(~cellfun('isempty',cfconds(:,:,ii)));    
         % check that cfconds is consistent with cfshocks
         % identify the non-empty elements in cfshocks
         [nerows2 neclmns2]=find(~cellfun('isempty',cfshocks(:,:,ii))); 
            % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
            if size(nerows1,1)~=size(nerows2,1)
            message=['conditional forecast error: the conditions for unit ' Units{ii} ' seem to be inconsistent with the shocks. Please verify that the ''pan conditions'' and ''pan shocks'' sheets of the Excel data file are properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error'); 
            % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
            elseif (~isempty(find(nerows1-nerows2)) || ~isempty(find(neclmns1-neclmns2)))
            message=['conditional forecast error: the conditions for unit ' Units{ii} ' seem to be inconsistent with the shocks. Please verify that the ''pan conditions'' and ''pan shocks'' sheets of the Excel data file are properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error'); 
            end
         % similarly, check that cfconds is consistent with cfblocks
         % first turn cfblocks to cell
         temp=num2cell(cfblocks(:,:,ii));
         % switch zero entries to empty entries
         temp(cellfun(@(x) any(~(x)),temp))={[]};  
         % identify the non-empty elements in cfblocks
         [nerows3 neclmns3]=find(~cellfun('isempty',temp));  
         % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
            if size(nerows1,1)~=size(nerows3,1)
            message=['conditional forecast error: the conditions for unit ' Units{ii} ' seem to be inconsistent with the blocks. Please verify that the ''pan conditions'' and ''pan blocks'' sheets of the Excel data file are properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error'); 
            % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
            elseif (~isempty(find(nerows1-nerows2)) || ~isempty(find(neclmns1-neclmns2)))
            message=['conditional forecast error: the conditions for unit ' Units{ii} ' seem to be inconsistent with the blocks. Please verify that the ''pan conditions'' and ''pan blocks'' sheets of the Excel data file are properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error'); 
            end 
         end
      end  
   end
   
   
   
   
   
%else if the panel model is 5 or 6
elseif panel==5 || panel==6
   % if the type of conditional forecasts is shock-specific
   if CFt==2           
   % identify the non-empty elements in cfconds
   [nerows1 neclmns1]=find(~cellfun('isempty',cfconds));    
   % check that cfconds is consistent with cfshocks
   % identify the non-empty elements in cfshocks
   [nerows2 neclmns2]=find(~cellfun('isempty',cfshocks));    
      % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
      if size(nerows1,1)~=size(nerows2,1)
      message=['conditional forecast error: the conditions seem to be inconsistent with the shocks. Please verify that the ''pan conditions'' and ''pan shocks'' sheets of the Excel data file is properly filled.'];
      msgbox(message);
      error('programme termination: conditional forecast error'); 
      % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
      elseif (~isempty(find(nerows1-nerows2)) || ~isempty(find(neclmns1-neclmns2)))
      message=['conditional forecast error: the conditions seem to be inconsistent with the shocks. Please verify that the ''pan conditions'' and ''pan shocks'' sheets of the Excel data file is properly filled.'];
      msgbox(message);
      error('programme termination: conditional forecast error'); 
      end        
   % similarly, check that cfconds is consistent with cfblocks
   % first turn cfblocks to cell
   temp=num2cell(cfblocks);
   % switch zero entries to empty entries
   temp(cellfun(@(x) any(~(x)),temp))={[]};  
   % identify the non-empty elements in cfblocks
   [nerows3 neclmns3]=find(~cellfun('isempty',temp));           
      % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
      if size(nerows1,1)~=size(nerows3,1)
      message=['conditional forecast error: the conditions seem to be inconsistent with the blocks. Please verify that the ''pan conditions'' and ''pan blocks'' sheets of the Excel data file is properly filled.'];
      msgbox(message);
      error('programme termination: conditional forecast error'); 
      % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
      elseif (~isempty(find(nerows1-nerows3)) || ~isempty(find(neclmns1-neclmns3)))
      message=['conditional forecast error: the conditions seem to be inconsistent with the blocks. Please verify that the ''pan conditions'' and ''pan blocks'' sheets of the Excel data file is properly filled.'];
      msgbox(message);
      error('programme termination: conditional forecast error'); 
      end             
   end      
end           
           
           



