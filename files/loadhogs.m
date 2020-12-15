function [grid]=loadhogs(scoeff,iobs,pref)








% initiate the grid
grid=cell(7,3);

% load the data from Excel
[num txt strngs]=xlsread('data.xlsx','grid');

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

% fill the grid
grid{1,1}=str2num(strngs{3,2});
grid{1,2}=str2num(strngs{3,3});
grid{1,3}=str2num(strngs{3,4});
grid{2,1}=str2num(strngs{4,2});
grid{2,2}=str2num(strngs{4,3});
grid{2,3}=str2num(strngs{4,4});
grid{3,1}=str2num(strngs{5,2});
grid{3,2}=str2num(strngs{5,3});
grid{3,3}=str2num(strngs{5,4});
grid{4,1}=str2num(strngs{6,2});
grid{4,2}=str2num(strngs{6,3});
grid{4,3}=str2num(strngs{6,4});
grid{5,1}=str2num(strngs{7,2});
grid{5,2}=str2num(strngs{7,3});
grid{5,3}=str2num(strngs{7,4});
grid{6,1}=str2num(strngs{8,2});
grid{6,2}=str2num(strngs{8,3});
grid{6,3}=str2num(strngs{8,4});
grid{7,1}=str2num(strngs{9,2});
grid{7,2}=str2num(strngs{9,3});
grid{7,3}=str2num(strngs{9,4});


% return error if some entry is missing
if isempty(grid{1,1})
message='Grid search error: the minimum value for the autoregressive coefficient in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{2,1})
message='Grid search error: the minimum value for the overall tightness hyperparameter (lambda1) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{3,1})
message='Grid search error: the minimum value for the cross-variable weighting hyperparameter (lambda2) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{4,1})
message='Grid search error: the minimum value for the lag decay hyperparameter (lambda3) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');    
elseif isempty(grid{5,1})
message='Grid search error: the minimum value for the exogenous variable tightness hyperparameter (lambda4) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{6,1}) && scoeff==1
message='Grid search error: the minimum value for the sum-of-coefficient tightness hyperparameter (lambda6) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{7,1}) && iobs==1
message='Grid search error: the minimum value for the dummy initial observation tightness hyperparameter (lambda7) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{1,2})
message='Grid search error: the maximum value for the autoregressive coefficient in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{2,2})
message='Grid search error: the maximum value for the overall tightness hyperparameter (lambda1) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{3,2})
message='Grid search error: the maximum value for the cross-variable weighting hyperparameter (lambda2) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{4,2})
message='Grid search error: the maximum value for the lag decay hyperparameter (lambda3) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');    
elseif isempty(grid{5,2})
message='Grid search error: the maximum value for the exogenous variable tightness hyperparameter (lambda4) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{6,2}) && scoeff==1
message='Grid search error: the maximum value for the sum-of-coefficient tightness hyperparameter (lambda6) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{7,2}) && iobs==1
message='Grid search error: the maximum value for the dummy initial observation tightness hyperparameter (lambda7) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{1,3})
message='Grid search error: the step value for the autoregressive coefficient in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{2,3})
message='Grid search error: the step value for the overall tightness hyperparameter (lambda1) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{3,3})
message='Grid search error: the step value for the cross-variable weighting hyperparameter (lambda2) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{4,3})
message='Grid search error: the step value for the lag decay hyperparameter (lambda3) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');    
elseif isempty(grid{5,3})
message='Grid search error: the step value for the exogenous variable tightness hyperparameter (lambda4) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{6,3}) && scoeff==1
message='Grid search error: the step value for the sum-of-coefficient tightness hyperparameter (lambda6) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error');
elseif isempty(grid{7,3}) && iobs==1
message='Grid search error: the step value for the dummy initial observation tightness hyperparameter (lambda7) in the grid is either empty or non-numerical. Please verify that the ''grid'' sheet of the Excel data file is properly filled.';
msgbox(message);
error('programme termination: grid search error'); 
end

% if no error is returned, record on Excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],grid,'grid search','C3');
end 
 
 
 
 
 
 
 
 
 
 
 
