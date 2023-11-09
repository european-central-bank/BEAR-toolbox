function [cfconds, cfshocks, cfblocks, cfintervals]=loadcf(endo,CFt,Fstartdate,Fenddate,Fperiods,pref)


% identify the number of endogenous variables
numendo=size(endo,1);

% initiate the cells
cfshocks={};
cfblocks=[];
cfintervals={};


% recover the cfconds cell (for all types of conditional forecasts)
Conditions = pref.data.Conditions;
condTime = string(Conditions.Time);
% identify the rows coresponding respectively to the forecast start date and forecast end dates
temp=find(strcmp(condTime,Fstartdate));
% if empty, return an error
if isempty(temp)
    message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''conditions'' sheet of the Excel data file is properly filled.'];
    msgbox(message);
    error('programme termination: conditional forecast error');
end
% otherwise, record
rows(1,1)=temp;
temp=find(strcmp(condTime,Fenddate));
% if empty, return an error
if isempty(temp)
    message= "conditional forecast error: forecast end date " + Fenddate + " cannot be found. Please verify that the 'conditions' sheet of the Excel data file is properly filled.";
    msgbox(message);
    error('programme termination: conditional forecast error');
end
% otherwise, record
rows(2,1)=temp;

Conditions = Conditions(rows(1):rows(2), :);
nanConds = isnan(Conditions{:,:});
cfconds = table2cell(Conditions);
cfconds(nanConds) = {[]};

% 
% 
% % nanConds = isnan(Conditions{:,:});
% % Conditions = table2cell(Conditions);
% % Conditions(nanConds) = {[]};
% 
% 
% % load the data from Excel
% [~, ~, strngs]=xlsread(pref.data.InputFile,'conditions');
% 
% % replace NaN entries by blanks
% strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
% % convert potential numeric entries into strings
% strngs(cellfun(@isnumeric,strngs))=cellfun(@num2str,strngs(cellfun(@isnumeric,strngs)),'UniformOutput',0);
% % identify the non_empty entries (pairs of rows and columns)
% [nerows, neclmns]=find(~cellfun('isempty',strngs));
% % count the number of such entries
% neentries=size(nerows,1);
% % all these entries contrain strings: fix them to correct potential user formatting errors
% % loop over entries
% for ii=1:neentries
%     strngs{nerows(ii,1),neclmns(ii,1)}=bear.utils.fixstring(strngs{nerows(ii,1),neclmns(ii,1)});
% end
% % recover the column corresponding to each endogenous variable
% % loop over endogenous variables
% for ii=1:numendo
%     % find the corresponding row
%     [~,c]=find(strcmp(strngs,endo{ii,1}));
%     % if the variable cannot be found, return an error
%     if size(c,1)==0
%         message=['conditional forecast error: endogenous variable ' endo{ii,1} ' cannot be found. Please verify that the ''conditions'' sheet of the Excel data file is properly filled.'];
%         msgbox(message);
%         error('programme termination: conditional forecast error');
%     end
%     % record it
%     clmns(ii,1)=c;
% end
% % identify the rows coresponding respectively to the forecast start date and forecast end dates
% temp=find(strcmp(strngs,Fstartdate));
% % if empty, return an error
% if isempty(temp)
%     message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''conditions'' sheet of the Excel data file is properly filled.'];
%     msgbox(message);
%     error('programme termination: conditional forecast error');
% end
% % otherwise, record
% rows(1,1)=temp;
% temp=find(strcmp(strngs,Fenddate));
% % if empty, return an error
% if isempty(temp)
%     message= "conditional forecast error: forecast end date " + Fenddate + " cannot be found. Please verify that the 'conditions' sheet of the Excel data file is properly filled.";
%     msgbox(message);
%     error('programme termination: conditional forecast error');
% end
% % otherwise, record
% rows(2,1)=temp;
% % record the values in cfconds
% % loop over endogenous variables
% for ii=1:numendo
%     % loop over forecast periods
%     for jj=1:Fperiods
%         % fill the corresponding entry
%         cfconds{jj,ii}=str2num(strngs{rows(1,1)+jj-1,clmns(ii,1)});
%     end
% end


% if no error is returned, record on Excel
if pref.results==1
    pref.exporter.writeCfConditions(pref.data.Conditions);
end


if CFt==2
    %% recover the cfshocks cell (only for shock-specific conditional forecasts)
    Shocks = pref.data.Shocks;
    dateString = string(Shocks.Time);
    assert(isequal(Shocks.Properties.VariableNames, endo'), ...
        'bear:loadcf:ConditionalForecastError', ...
        "Shocks table is missing an endogenous variable. Please verify that the ''blocks'' sheet of the Excel data file is properly filled.")

    % identify the rows coresponding respectively to the forecast start date and forecast end dates
    temp=find(strcmp(dateString,Fstartdate));
    % if empty, return an error
    if isempty(temp)
        message= "conditional forecast error: forecast start date " + Fstartdate + " cannot be found. Please verify that the ''shocks'' sheet of the Excel data file is properly filled.";
        error('bear:loadcf:ConditionalForecastError', message);
    end
    % otherwise, record
    rows(1,1)=temp;
    temp=find(strcmp(dateString,Fenddate));
    % if empty, return an error
    if isempty(temp)
        message=['conditional forecast error: forecast end date ' Fenddate ' cannot be found. Please verify that the ''shocks'' sheet of the Excel data file is properly filled.'];
        msgbox(message);
        error('programme termination: conditional forecast error');
    end
    % otherwise, record
    rows(2,1)=temp;

    cfshocks = Shocks(rows(1):rows(2),:);
    cfshocks = num2cell(cfshocks{:,:});
    cfshocks(cellfun(@isnan, cfshocks)) = {[]};

    %% recover the cfblocks matrix (only for shock-specific conditional forecasts)

    % load the data from Excel
    Blocks = pref.data.Blocks;
    dateString = string(Blocks.Time);
    assert(isequal(Blocks.Properties.VariableNames, endo'), ...
        'bear:loadcf:ConditionalForecastError', ...
        "Shocks table is missing an endogenous variable. Please verify that the ''blocks'' sheet of the Excel data file is properly filled.")

    % identify the rows coresponding respectively to the forecast start date and forecast end dates
    temp=find(strcmp(dateString,Fstartdate));
    % if empty, return an error
    if isempty(temp)
        message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''blocks'' sheet of the Excel data file is properly filled.'];
        error('bear:loadcf:ConditionalForecastError', message);
    end
    % otherwise, record
    rows(1,1)=temp;
    temp=find(strcmp(dateString,Fenddate));
    % if empty, return an error
    if isempty(temp)
        message=['conditional forecast error: forecast end date ' Fenddate ' cannot be found. Please verify that the ''blocks'' sheet of the Excel data file is properly filled.'];
        error('bear:loadcf:ConditionalForecastError', message);
    end
    % otherwise, record
    rows(2,1)=temp;

    % initiate the cfblocks matrix
    cfblocks = Blocks{rows(1):rows(2),:};
    cfblocks(isnan(cfblocks)) = 0;
    
    %% if no error is returned, record on Excel
    if pref.results==1
        pref.exporter.writeCfShocks(Shocks);
        pref.exporter.writeCfBlocks(Blocks);
    end

    % final verification: check that cfconds is consistent with the other cells/matrices (i.e. cfshocks, cfblocks and cfintervals)
    % identify the non-empty elements in cfconds
    [nerows1, neclmns1]=find(~cellfun('isempty',cfconds));

    % if the type of conditional forecasts is shock-specific
    % check that cfconds is consistent with cfshocks
    % identify the non-empty elements in cfshocks
    [nerows2, neclmns2]=find(~cellfun('isempty',cfshocks));
    % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
    if size(nerows1,1)~=size(nerows2,1)
        message="conditional forecast error: the conditions seem to be inconsistent with the shocks. Please verify that the ''conditions'' and ''shocks'' sheets of the Excel data file are properly filled.";
        error('bear:loadcf:ConditionalForecastError', message);
        % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
    elseif (~isempty(find(nerows1-nerows2, 1)) || ~isempty(find(neclmns1-neclmns2, 1)))
        message="conditional forecast error: the conditions seem to be inconsistent with the shocks. Please verify that the ''conditions'' and ''shocks'' sheets of the Excel data file are properly filled.";
        error('bear:loadcf:ConditionalForecastError', message);
    end
    % similarly, check that cfconds is consistent with cfblocks
    % first turn cfblocks to cell
    temp=num2cell(cfblocks);
    % switch zero entries to empty entries
    temp(cellfun(@(x) any(~(x)),temp))={[]};
    % identify the non-empty elements in cfblocks
    [nerows3, neclmns3]=find(~cellfun('isempty',temp));
    % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
    if size(nerows1,1)~=size(nerows3,1)
        message="conditional forecast error: the conditions seem to be inconsistent with the blocks. Please verify that the ''conditions'' and ''blocks'' sheets of the Excel data file are properly filled.";
        error('bear:loadcf:ConditionalForecastError', message);
        % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
    elseif (~isempty(find(nerows1-nerows3, 1)) || ~isempty(find(neclmns1-neclmns3, 1)))
        message="conditional forecast error: the conditions seem to be inconsistent with the blocks. Please verify that the ''conditions'' and ''blocks'' sheets of the Excel data file are properly filled.";
        error('bear:loadcf:ConditionalForecastError', message);
    end
    
end

%% recover the cfintervals cell (only for tilting conditional forecasts)
if CFt==4    

    % load the data from Excel
    [~, ~, strngs]=xlsread(pref.data.InputFile,'intervals');
    % replace NaN entries by blanks
    strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
    % convert potential numeric entries into strings
    strngs(cellfun(@isnumeric,strngs))=cellfun(@num2str,strngs(cellfun(@isnumeric,strngs)),'UniformOutput',0);
    % identify the non-empty entries (pairs of rows and columns)
    [nerows, neclmns]=find(~cellfun('isempty',strngs));
    % count the number of such entries
    neentries=size(nerows,1);
    % all these entries contrain strings: fix them to correct potential user formatting errors
    % loop over entries
    for ii=1:neentries
        strngs{nerows(ii,1),neclmns(ii,1)}=bear.utils.fixstring(strngs{nerows(ii,1),neclmns(ii,1)});
    end
    % recover the column corresponding to each endogenous variable
    % loop over endogenous variables
    for ii=1:numendo
        % find the corresponding row
        [~,c]=find(strcmp(strngs,endo{ii,1}));
        % if the variable cannot be found, return an error
        if size(c,1)==0
            message=['conditional forecast error: endogenous variable ' endo{ii,1} ' cannot be found. Please verify that the ''blocks'' sheet of the Excel data file is properly filled.'];
            msgbox(message);
            error('programme termination: conditional forecast error');
        end
        % record it
        clmns(ii,1)=c;
    end
    % identify the rows coresponding respectively to the forecast start date and forecast end dates
    temp=find(strcmp(strngs,Fstartdate));
    % if empty, return an error
    if isempty(temp)
        message=['conditional forecast error: forecast start date ' Fstartdate ' cannot be found. Please verify that the ''intervals'' sheet of the Excel data file is properly filled.'];
        msgbox(message);
        error('programme termination: conditional forecast error');
    end
    % otherwise, record
    rows(1,1)=temp;
    temp=find(strcmp(strngs,Fenddate));
    % if empty, return an error
    if isempty(temp)
        message=['conditional forecast error: forecast end date ' Fenddate ' cannot be found. Please verify that the ''intervals'' sheet of the Excel data file is properly filled.'];
        msgbox(message);
        error('programme termination: conditional forecast error');
    end
    % otherwise, record
    rows(2,1)=temp;
    % record the values in cfshocks
    % loop over endogenous variables
    for ii=1:numendo
        % loop over forecast periods
        for jj=1:Fperiods
            % fill the corresponding entry
            cfintervals{jj,ii}=str2num(strngs{rows(1,1)+jj-1,clmns(ii,1)});
        end
    end
    % if no error is returned, record on Excel
    if pref.results==1
        bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),strngs,'cf intervals','B2');
    end

    % final verification: check that cfconds is consistent with the other cells/matrices (i.e. cfshocks, cfblocks and cfintervals)
    % identify the non-empty elements in cfconds
    [nerows1, neclmns1]=find(~cellfun('isempty',cfconds));
    
    % if the type of conditional forecasts is shock-specific
    % check that cfconds is consistent with cfintervals
    % identify the non-empty elements in cfintervals
    [nerows2, neclmns2]=find(~cellfun('isempty',cfintervals));
    % if the number of non-empty elements is not similar in the two cells, there is obvioulsy a problem: return an error
    if size(nerows1,1)~=size(nerows2,1)
        message="conditional forecast error: the conditions seem to be inconsistent with the intervals. Please verify that the ''conditions'' and ''intervals'' sheets of the Excel data file are properly filled.";
        msgbox(message);
        error('programme termination: conditional forecast error');
        % else, if there a is a similar number of non-empty entries but they don't match, there is also a problem: return an error
    elseif (~isempty(find(nerows1-nerows2)) || ~isempty(find(neclmns1-neclmns2)))
        message="conditional forecast error: the conditions seem to be inconsistent with the intervals. Please verify that the ''conditions'' and ''intervals'' sheets of the Excel data file are properly filled.";
        msgbox(message);
        error('programme termination: conditional forecast error');
    end

end