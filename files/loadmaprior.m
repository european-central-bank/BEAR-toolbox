function [equilibrium,chvar,regimeperiods,Fpconfint,Fpconfint2,regime1,regime2,Dmatrix]=loadmaprior(endo,exo,startdate,pref,data_endo)

%This function reads the prior information for the Time Varying Equilibrium VAR mean-adjusted steady-state from the EXCEL spreadsheet 'mean adj prior'
%inputs:  - cell 'endo': list of endogenous variables of the model
%         - cell 'exo': list of exogenous variables of the model
%         - string 'datapath': user-supplied path to excel data spreadsheet
%outputs: - cell 'Trendtype': Type of trend the user has specified: '1' for constant trend, '2' for linear trend and '3' for quadratic trend
%         - cell 'Fpconfint': prior mean confidence interval
%         - cell 'regime 1': credibility interval for the steady state in regime 1
%         - cell 'regime 2': credibility interval for the steady state in regime 2


% identify the number of endogenous variables
numendo=size(endo,1);
% identify the number of exogenous variables (other than the constant)
numexo=size(exo,1);
% generate the cell Trendtype
Trendtype=cell(numendo,1);
% generate double array equilibrium
equilibrium=[];
% generate array of regime changes
chvar=[];
% regime periods
regimeperiods=[];
% generate the cell Fpconfint for the first steady-state regime
Fpconfint=cell(numendo,numexo+1);
% generate the cell Fpconfint for the second steady-state regime
Fpconfint2=cell(numendo,numexo+1);
% generate the cell regime 1 for the steady-state regime (if different from constant)
regime1=cell(numendo,numexo+1);
% generate the cell regime 2 for the second steady-state regime (if different from constant)
regime2=cell(numendo,numexo+1);
% Creation of the D matrix
Dmatrix=[];

% load the data from Excel
[num txt strngs]=xlsread('data.xlsx','mean adj prior');
% replace NaN entries by blanks
strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
% identify the non_empty entries (pairs of rows and columns)
[nerows neclmns]=find(~cellfun('isempty',strngs));
% count the number of such entries
neentries=size(nerows,1);
% all these entries contrain strings: fix them to correct potential user formatting errors
% loop over entries
for ii=1:neentries
strngs{nerows(ii,1),neclmns(ii,1)}=fixstring(strngs{nerows(ii,1),neclmns(ii,1)});
end


% recover the row corresponding to each endogenous variable
% loop over endogenous variables
for ii=1:numendo
% find the corresponding row
[r,~]=find(strcmp(strngs,endo{ii,1}));
   % if the row cannot be found, return an error
   if isempty(r)
   message=['Mean-adjusted prior error: endogenous variable ' endo{ii,1} ' cannot be found. Please verify that the ''mean adj prior'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: mean-adjusted prior error');   
   end
% if no error, record the row
rows(ii,1)=max(r);
end


% record the type of trend to implement fo the 
% find the column containing the constant string
[~,c]=find(strcmp(strngs,'trend'));
% if 'trend' cannot be found, return an error
if isempty(c)
message=['Trend error: Trend cannot be found. Please verify that the ''mean adj prior'' sheet of the Excel data file is properly filled.'];
msgbox(message);
error('programme termination: error in trend specification');   
end
% record as the first column of interest
clmns(1,1)=c;
% loop over endogenous variables
for ii=1:numendo
% identify the value (it is a string)
temp1=strngs{rows(ii,1),clmns(1,1)};
% record the values in the cell Trendtype
Trendtype{ii,1}=temp1;
equilibrium=str2double(Trendtype)';
end


% record the prior value corresponding to the trend specification 
% find the column containing the constant string
[~,c]=find(strcmp(strngs,'trend prior'));
% if 'prior regime' cannot be found, return an error
if isempty(c)
message=['Mean-adjusted prior error: prior regime 1 cannot be found. Please verify that the ''mean adj prior'' sheet of the Excel data file is properly filled.'];
msgbox(message);
error('programme termination: mean-adjusted prior error');   
end
% record as the first column of interest
clmns(1,1)=c;
% loop over endogenous variables
for ii=1:numendo
% identify the value (it is a string)
temp1=strngs{rows(ii,1),clmns(1,1)};
% find the space within the string
locspace=find(isspace(temp1));
% identify the two values and convert them into numbers
if isempty(temp1)==1
    Fpconfint{ii,1}=NaN;
else
temp2=str2double(temp1(1,1:locspace-1));
temp3=str2double(temp1(1,locspace+1:end));
% record the values in the cell Fpconfint
Fpconfint{ii,1}=[temp2 temp3];
end
end



% record the prior value corresponding to the constant (regime 1)
% find the column containing the constant string
[~,c]=find(strcmp(strngs,'regime 1'));
% if 'prior regime' cannot be found, return an error
if isempty(c)
message=['Mean-adjusted prior error: prior regime 1 cannot be found. Please verify that the ''mean adj prior'' sheet of the Excel data file is properly filled.'];
msgbox(message);
error('programme termination: mean-adjusted prior error');   
end
% record as the first column of interest
clmns(1,1)=c;
% loop over endogenous variables
for ii=1:numendo
% identify the value (it is a string)
temp1=strngs{rows(ii,1),clmns(1,1)};
% find the space within the string
locspace=find(isspace(temp1));
% identify the two values and convert them into numbers
if isempty(temp1)==1
    regime1{ii,1}=[];
else
temp2=temp1(1,1:locspace-1);
temp3=temp1(1,locspace+1:end);
% record the values in the cell Fpconfint
regime1{ii,1}=[{temp2},{temp3}];
end
end

% needs to be generalized (for now only first regime and first variable)

for ii=1:numendo
    if isempty(regime1{ii})==0;
        chvar(ii,1)=1;
    else
        chvar(ii,1)=0;
    end
end
chvar=chvar';
indchvar=find(chvar==1);
if length(indchvar)>0;
    regimeperiods=regime1{indchvar(1)};
else 
    regimeperiods=[];
end
% record the prior value corresponding to the constant (regime 2)
% find the column containing the constant string
[~,c]=find(strcmp(strngs,'trend prior 2'));
% if 'constant' cannot be found, return an error
if isempty(c)
message=['Mean-adjusted prior error: prior regime 2 cannot be found. Please verify that the ''mean adj prior'' sheet of the Excel data file is properly filled.'];
msgbox(message);
error('programme termination: mean-adjusted prior error');   
end
% record as the first column of interest
clmns(1,1)=c;
% loop over endogenous variables
for ii=1:numendo
% identify the value (it is a string)
temp1=strngs{rows(ii,1),clmns(1,1)};
% find the space within the string
locspace=find(isspace(temp1));
% identify the two values and convert them into numbers
if isempty(temp1)==1
    Fpconfint2{ii,1}=NaN;
else
temp2=str2double(temp1(1,1:locspace-1));
temp3=str2double(temp1(1,locspace+1:end));
% record the values in the cell Fpconfint
Fpconfint2{ii,1}=[temp2 temp3];
end
end


% record the prior value corresponding to the other exogenous (if any)
% loop over exogenous
for ii=1:numexo
% find the column containing the name of the exogenous
[~,c]=find(strcmp(strngs,exo{ii,1}));
% if this exogenous cannot be found, return an error
if isempty(c)
message=['Mean-adjusted prior error: exogenous variable ' exo{ii,1} ' cannot be found. Please verify that the ''mean adj prior'' sheet of the Excel data file is properly filled.'];
msgbox(message);
error('programme termination: mean-adjusted prior error');   
end
% if no error, record
clmns(1+ii,1)=max(c);
   % loop over exogenous variables
   for jj=1:numendo
   % identify the value (it is a string)
   temp1=strngs{rows(jj,1),clmns(1+ii,1)};
   % find the space within the string
   locspace=find(isspace(temp1));
   % identify the two values and convert them into numbers
   temp2=str2num(temp1(1,1:locspace-1));
   temp3=str2num(temp1(1,locspace+1:end));
   % record the values in the cell Fpconfint
   Fpconfint{jj,1+ii}=[temp2 temp3];
   end
end

% Create D Matrix
T=length(data_endo(:,1));
Dmatrix = TVEregimesDummy(startdate,regimeperiods,T);

% finally, record on Excel
xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs,'mean-adj prior','B2');


