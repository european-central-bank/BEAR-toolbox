function [names, data, data_endo, data_endo_a, data_endo_c, data_endo_c_lags, data_exo, data_exo_a, data_exo_p, data_exo_c, data_exo_c_lags, Fperiods, Fcomp, Fcperiods, Fcenddate,endo,numendo,favar]=gensampleols(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,favar,IRFt)

% if we have a FaVAR: read information data, data transformation, create indices, compute factors (PC)
if favar.FAVAR==1
    [informationstartlocation,informationendlocation,favar]=favar_gensample1(startdate,enddate,favar);
end

%% endo data
% Phase 1: data loading and error checking
% first read the data from Excel
[data, names]=xlsread('data.xlsx','data');

% identify the date strings
datestrings=names(2:end,1);
% identify the position of the string corresponding to the start period
startlocation=find(strcmp(datestrings,startdate));
% identify the position of the string corresponding to the end period
endlocation=find(strcmp(datestrings,enddate));

if favar.FAVAR==1 % in case we transform the data to first or second differences, we have a different startlocation
    if favar.transformation==1
        startlocation=informationstartlocation;
        endlocation=informationendlocation;
        datestrings=names(1+favar.informationstartlocation:end,:); %first row are labels
    end
end

% save the whole sample temporarily for FAVARs
data1=data;

% adjust data to startdate and enddate
data=data(startlocation:endlocation,:);

% identify the variable strings, endogenous and exogenous
variablestrings=names(1,2:end);

% FAVAR: augment data and variablestrings with factors
if favar.FAVAR==1
    [data,variablestrings,favar]=favar_gensample2(data1,endo,variablestrings,startlocation,lags,favar);
end

% if either the start date or the date date is not recognised, return an error message
if isempty(startlocation)
    msgbox('Error: unknown start date for the sample. Please check your sample start date (remember that names are case-sensitive).');
    error('programme termination: date error');
elseif isempty(endlocation)
    msgbox('Error: unknown end date for the sample. Please check your sample end date (remember that names are case-sensitive).');
    error('programme termination: date error');
end
% also, if the start date is posterior to the end date, obviously return an error
if startlocation>=endlocation==1
    msgbox('Error: inconsistency between the start and end dates. The start date must be anterior to the end date.');
    error('programme termination: date error');
end

% identify the position of the strings corresponding to the endogenous variables
% count the number of endogenous variables
numendo=size(endo,1);
% for each variable, find the corresponding string
for ii=1:numendo
    % check first that the variable ii in endo appears in the list of variable strings
    % if not, the variable is unknown: return an error
    var=endo{ii,1};
    check=find(strcmp(variablestrings,var),1);
    if isempty(check)==1
        message=['Error: endogenous variable ' var ' cannot be found on the excel data spreadsheet.'];
        msgbox(message);
        error('programme termination: data error');
    end
    % if the variable is known, go on
    endolocation(ii,1)=find(strcmp(variablestrings,endo(ii,1)));
end

% identify the position of the strings corresponding to the exogenous variables
% proceed similarly to the endogenous variables, but account for the fact that exogenous may be empty
% so check first whether there are exogenous variables altogether
if isempty(exo)
    numexo=0;
else
    % if not empty, repeat what has been done with the exogenous
    numexo=size(exo,1);
    % for each variable, find the corresponding string
    for ii=1:numexo
        % check first that the variable ii in endo appears in the list of variable strings
        % if not, the variable is unknown: return an error
        var=exo{ii,1};
        check=find(strcmp(variablestrings,var), 1);
        if isempty(check)==1
            message=['Error: exogenous variable ' var ' cannot be found on the excel data spreadsheet.'];
            msgbox(message);
            error('programme termination: data error');
        end
        % if the variable is known, go on
        exolocation(ii,1)=find(strcmp(variablestrings,exo(ii,1)));
    end
end

% Phase 2: creation of the data matrices data_endo and data_exo

% now create the matrix of endogenous variables for the estimation sample
% it is simply the concatenation of the vectors of each endogenous variables, over the selected sample dates
data_endo=[];
% loop over endogenous variables
for ii=1:numendo
    data_endo=[data_endo data(:,endolocation(ii,1))];
end

% Similarly, create the matrix of exogenous variables for the estimation sample
data_exo=[];
for ii=1:numexo
    data_exo=[data_exo data(startlocation:endlocation,exolocation(ii,1))];
end

% this NaN test has to be adjustted to the actual endo sample
% now, as a preliminary step: check if there is any Nan in the data; if yes, return an error since the model won't be able to run with missing data
% a simple way to test for NaN is to check for "smaller or equal to infinity": Nan is the only number for which matlab will return 'false' when asked so
[r,c]=size(data);
for ii=1:r
    for jj=1:c
        temp=data(ii,jj);
        if (temp<=inf)==0
            % identify the variable and the date
            NaNvariable=names{1,jj+1};
            NaNdate=names{ii+1,1};
            message=['Error: variable ' NaNvariable ' at date ' NaNdate ' (and possibly other sample entries) is identified as NaN. Please check your Excel spreadsheet: entry may be blank or non-numerical.'];
            msgbox(message);
            error('programme termination: data error');
        end
    end
end

if favar.FAVAR==1
    if favar.transformation==1
        % correct order of transformationindex_endo
        favar.transformationindex_endo=[];
        for ii=1:size(endo,1)
            favar.transformationindex_endo=[favar.transformationindex_endo favar.transformationindex_endo_temp(:,endolocation(ii,1))];
        end
    end
    % correct order of stddev
    favar.data_exfactors_stddev=[];
    for ii=1:size(endo,1)
        favar.data_exfactors_stddev=[favar.data_exfactors_stddev favar.data_exfactors_stddev_temp(:,endolocation(ii,1))];
    end
    
    % determine the numbers of variables other than factors
    favar.numdata_exfactors=size(favar.data_exfactors,2);
    if favar.numdata_exfactors==0
        favar.slowfast=0; % this identifiaction is not applicable in a pure factor model
    end
    
    if favar.slowfast==1 % apply slowfast recursive identification as in BBE (2005)
        % factor roation with slow/fast scheme
        favar.XZ_rotated=favar_facrot(favar.XZ,favar.data_exfactors(:,end),favar.XZ_slow); %end, has eventually to be changed
        % replace factors with factors rotated
        for ii=1:size(favar.variablestrings_factorsonly)
            data_endo(:,favar.variablestrings_factorsonly(ii))=favar.XZ_rotated(:,ii);
        end
    end
    % save FY in favar structure
    favar.FY=data_endo;
    % state-space representation
    favar.XY=[favar.X,favar.data_exfactors];
    % new loadings
    %favar.L=(mvregress(data_endo,favar.XY,'algorithm','cwls'))'; %appears to be not feasible for very large X
    favar.L=(favar_olssvd(favar.XY,data_endo))';
    
    % to activate routines in the BVAR framwork and IRFt 4, where we have It-Bu
    % x X, Y and L
    favar.bvar=0;
    
    % IRF shock to plot
    if favar.IRF.plot==1
        if IRFt==1||IRFt==2||IRFt==3
            plotXshock_indexlogical=ismember(endo,favar.IRF.pltXshck);
            favar.IRF.plotXshock_index=find(plotXshock_indexlogical==1)';
            favar.IRF.npltXshck=size(favar.IRF.pltXshck,1);
            if favar.IRF.npltXshck==0
                % error if no shock to plot is found, otherwise code crashes at a later stage
                message=['Error: Shock(' favar.IRF.pltXshck ') cannot be found.'];
                msgbox(message,'favar.IRF.npltXshck error');
                error('programme termination: favar.IRF.npltXshck error');
            end
        end
        % for IRFt 4 & 6 this step is done in loadsignres
    end
    
    %with slow fast moving factors,... redundant, we use the facrot function
    %with slow fast moving factors: rotate factors
    %     if favar.slowfast==1
    %         %regressing the factors from all x on the slow moving factors and the FFR
    %         favar.Beta = mvregress(data_endo,favar.XZ);
    %         favar.Beta_exfactors = favar.Beta(favar.variablestrings_exfactors,:);
    %         favar.Frot=favar.XZ-favar.data_endo_exfactors*favar.Beta_exfactors;
    %         %replace factors with factors rotated
    %         for ii=1:size(favar.variablestrings_factorsonly)
    %           data_endo(:,favar.variablestrings_factorsonly(ii))=favar.Frot(:,ii);
    %         end
    %     end
end



% Phase 3: determination of the position of the forecast start and end periods

% if both unconditional and conditional forecasts were not selected, there is no need for all the forecast-specific matrices: simply return empty matrices
if (VARtype==1 && F==0)
    data_endo_a=[];
    data_exo_a=[];
    data_exo_p=[];
    Fperiods=[];
    Fcomp=[];
    Fcperiods=[];
    data_endo_c=[];
    data_endo_c_lags=[];
    data_exo_c=[];
    data_exo_c_lags=[];
    Fcenddate=[];
    
    % if forecast were selected, create all the required elements
else
    
    % preliminary tasks
    % first, identify the date strings, and the variable strings
    datestrings=names(2:end,1);
    if favar.FAVAR==1 % in case we transform the data to first or second differences, we have a different datestrings
        if favar.transformation==1
            datestrings=names(1+favar.informationstartlocation:end,:); %first row are labels
        end
    end
    variablestrings=names(1,2:end);
    
    % identify the location of the last period in the dataset
    dataendlocation=size(datestrings,1);
    
    % identify the position of the start period (the easy part)
    % if the start period has been selected as the first period after the sample end, identifies it directly
    if Fendsmpl==1
        Fstartlocation=find(strcmp(datestrings,enddate))+1;
        % if the start period has not been selected as the first period after the sample end, it must be within the sample: look for it
    elseif Fendsmpl==0
        Fstartlocation=find(strcmp(datestrings,Fstartdate));
        % if the start date is not recognised, return an error message
        if isempty(Fstartlocation)==1
            msgbox('Error: unknown start date for the forecasts. Select a date within a sample, or select "Start forecasts after last sample period"');
            error('unknown start date for the forecasts');
        end
    end
    
    % identify the position of the final forecast period (the hard part)
    % this period can be in or outside the sample, depending on the user's choice
    
    % if the data is yearly
    if frequency==1
        Fendlocation=str2num(Fenddate(1,1:end-1))-str2num(datestrings{1,1}(1,1:end-1))+1;
        
        % if the data is quarterly
    elseif frequency==2
        % first identify the year and quarter of the initial date in the whole data set (not just the sample)
        datastartyear=str2num(datestrings{1,1}(1,1:4));
        datastartquarter=str2num(datestrings{1,1}(1,6));
        % convert this date into quarters only
        datastart=datastartyear*4+datastartquarter;
        % then identify the year and quarter of the final forecast date
        forecastendyear=str2num(Fenddate(1,1:4));
        forecastendquarter=str2num(Fenddate(1,6));
        % convert this date into quarters only
        forecastend=forecastendyear*4+forecastendquarter;
        % finally, compute the number of periods that separate the two dates
        Fendlocation=forecastend-datastart+1;
        
        % if the data is monthly
    elseif frequency==3
        % first identify the year and month of the initial date in the whole data set (not just the sample)
        temp=datestrings{1,1};
        datastartyear=str2num(temp(1,1:4));
        temp(1,5)=' ';
        [~,datastartmonth]=strtok(temp);
        % convert this date into months only
        datastart=datastartyear*12+str2num(datastartmonth);
        % then identify the year and month of the final forecast date
        temp=Fenddate;
        forecastendyear=str2num(temp(1,1:4));
        temp(1,5)=' ';
        [~,forecastendmonth]=strtok(temp);
        % convert this date into months only
        forecastend=forecastendyear*12+str2num(forecastendmonth);
        Fendlocation=forecastend-datastart+1;
        
        % if the data is weekly
    elseif frequency==4
        % then identify the year and week corresponding to this final period
        temp=datestrings{end,1};
        dataendyear=str2num(temp(1,1:4));
        temp(1,5)=' ';
        [~,dataendweek]=strtok(temp);
        dataendweek=str2num(dataendweek);
        % identify the year and week corresponding to the end of the forecast period
        temp=Fenddate;
        Fendyear=str2num(temp(1,1:4));
        temp(1,5)=' ';
        [~,Fendweek]=strtok(temp);
        Fendweek=str2num(Fendweek);
        % determine whether the forecast period ends within the data set, or after the end of the data set
        if Fendyear<dataendyear
            insmpl=1;
        elseif Fendyear==dataendyear && Fendweek<=dataendweek
            insmpl=1;
        else
            insmpl=0;
        end
        % if the forecast end period lies within the dataset, simply detect its location
        if insmpl==1
            Fendlocation=find(strcmp(Fenddate,datestrings));
            % if it is outside the data set, complete until the forecast end date is reached (assuming 52 weeks per year)
        elseif insmpl==0
            % Consider two cases separately
            % first case: if the end year of the forecast is the same as the end year of the dataset
            % in this case, simply complete the missing periods
            if dataendyear==Fendyear
                complement=Fendweek-dataendweek;
                Fendlocation=dataendlocation+complement;
                % if the end year of the forecasts is posterior to the last year of the data
            elseif dataendyear<Fendyear
                % complete the first year (the one shared that ends the data set)
                complement=52-dataendweek;
                % complete the following years before the last one (if any)
                for ii=dataendyear+1:Fendyear-1
                    complement=complement+52;
                end
                % complete the final forecast year
                complement=complement+Fendweek;
                Fendlocation=dataendlocation+complement;
            end
        end
        
        % if the data is daily
    elseif frequency==5
        % then identify the year and day corresponding to this final period
        temp=datestrings{end,1};
        dataendyear=str2num(temp(1,1:4));
        temp(1,5)=' ';
        [~,dataendday]=strtok(temp);
        dataendday=str2num(dataendday);
        % identify the year and day corresponding to the end of the forecast period
        temp=Fenddate;
        Fendyear=str2num(temp(1,1:4));
        temp(1,5)=' ';
        [~,Fendday]=strtok(temp);
        Fendday=str2num(Fendday);
        % determine whether the forecast period ends within the data set, or after the end of the data set
        if Fendyear<dataendyear
            insmpl=1;
        elseif Fendyear==dataendyear && Fendday<=dataendday
            insmpl=1;
        else
            insmpl=0;
        end
        % if the forecast end period lies within the dataset, simply detect its location
        if insmpl==1
            Fendlocation=find(strcmp(Fenddate,datestrings));
            % if it is outside the data set, complete until the forecast end date is reached (assuming 261 opening days per year)
        elseif insmpl==0
            % Consider two cases separately
            % first case: if the end year of the forecast is the same as the end year of the dataset
            % in this case, simply complete the missing periods
            if dataendyear==Fendyear
                complement=Fendday-dataendday;
                Fendlocation=dataendlocation+complement;
                % if the end year of the forecasts is posterior to the last year of the data
            elseif dataendyear<Fendyear
                % complete the first year (the one shared that ends the data set)
                complement=261-dataendday;
                % complete the following years before the last one (if any)
                for ii=dataendyear+1:Fendyear-1
                    complement=complement+261;
                end
                % complete the final forecast year
                complement=complement+Fendday;
                Fendlocation=dataendlocation+complement;
            end
        end
        
        % finally, if the data is undated
    elseif frequency==6
        Fendlocation=str2num(Fenddate(1,1:end-1))-str2num(datestrings{1,1}(1,1:end-1))+1;
    end
    
    % from this, conclude the total number of forecast periods
    Fperiods=Fendlocation-Fstartlocation+1;
    
    if Fperiods<0
        msgbox('Error: The forecast start date needs to be prior to the forecast end date');
        error('invalid forecast start or end date');
    end
    
    
    % Phase 4: generation of the forecast-specific matrices
    if favar.FAVAR==0
        % load the full sample in this case
        data=data1;
    elseif favar.FAVAR==1
        data=favar.data_full;
    end
    
    % now create the matrix of endogenous variables for the pre-forecast period
    % it is simply the concatenation of the vectors of each endogenous variables, over the selected sample dates
    data_endo_a=[];
    % loop over endogenous variables
    for ii=1:numendo
        data_endo_a=[data_endo_a data(1:Fstartlocation-1,endolocation(ii,1))];
    end
    % also, create the matrix of exogenous variables for the pre-forecast period
    data_exo_a=[];
    for ii=1:numexo
        data_exo_a=[data_exo_a data(1:Fstartlocation-1,exolocation(ii,1))];
    end
    
    % create the matrix of endogenous variables for the period common to actual data and forecasts (for forecast evaluation)
    % first, check that there are such common periods: it is the case if the beginning of the forecast period is anterior to the end of the dataset
    if Fstartlocation<=dataendlocation
        % return a scalar value to indicate that forecast evaluation is possible
        Fcomp=1;
        % compute the number of common periods
        % if the forecast period ends before the end of the data set, the common periods end with the end of the forecasts
        if Fendlocation<=dataendlocation
            Fcperiods=Fperiods;
            % record the end date of the common periods
            Fcenddate=Fenddate;
            % if the forecast period ends later than the data set, the common periods end at the end of the data set
        elseif Fendlocation>dataendlocation
            Fcperiods=dataendlocation-Fstartlocation+1;
            % record the end date of the common periods
            Fcenddate=datestrings{end,1};
        end
        
        % create a matrix of endogenous data for the common periods
        data_endo_c=[];
        for ii=1:numendo
            data_endo_c=[data_endo_c data(Fstartlocation:min(dataendlocation,Fendlocation),endolocation(ii,1))];
        end
        
        % create a lagged matrix of endogenous data prior to the common periods
        % the number of values is equal to "lags"; this will be used for computation of the log predictive score
        data_endo_c_lags=[];
        for ii=1:numendo
            data_endo_c_lags=[data_endo_c_lags data(Fstartlocation-lags:Fstartlocation-1,endolocation(ii,1))];
        end
        
        % create a matrix of exogenous data for the common periods
        data_exo_c=[];
        for ii=1:numexo
            data_exo_c=[data_exo_c data(Fstartlocation:min(dataendlocation,Fendlocation),exolocation(ii,1))];
        end
        
        % create a lagged matrix of exogenous data prior to the common periods
        % the number of values is equal to "lags"; this will be used for computation of the log predictive score
        data_exo_c_lags=[];
        for ii=1:numexo
            data_exo_c_lags=[data_exo_c_lags data(Fstartlocation-lags:Fstartlocation-1,exolocation(ii,1))];
        end
        % if there are no common periods, return a scalar value to indicate that forecast evaluation is not possible
    else
        Fcomp=0;
        Fcperiods=0;
        data_exo_c=[];
        data_endo_c=[];
        Fcenddate=[];
        data_endo_c_lags=[];
        data_exo_c_lags=[];
    end
    
    
    % now create the matrix data_exo_p
    % two possible cases
    
    % if there are no exogenous variables, simply create an empty matrix
    if isempty(exo)
        data_exo_p=[];
        
        % if there are exogenous variables, load from excel
    else
        % load the data from Excel
        [~,~,strngs]=xlsread('data.xlsx','pred exo');
        
        % obtain the row location of the forecast start date
        [Fstartlocation,~]=find(strcmp(strngs,Fstartdate));
        % check that the start date for the forecast appears in the sheet; if not, return an error
        if isempty(Fstartlocation)
            message=['Error: a forecast application is selected for a model that uses exogenous variables. Hence, predicted exogenous values should be supplied over the forecast periods. Yet the start date for forecasts (' Fstartdate ') cannot be found on the ''pred exo'' sheet of the Excel data file. Please verify that this sheet is properly filled, and remember that dates are case-sensitive.'];
            msgbox(message);
            error('programme termination: data error');
        end
        % obtain the row location of the forecast end date
        [Fendlocation,~]=find(strcmp(strngs,Fenddate));
        % check that the end date for the forecast appears in the sheet; if not, return an error
        if isempty(Fendlocation)
            message=['Error: a forecast application is selected for a model that uses exogenous variables. Hence, predicted exogenous values should be supplied over the forecast periods. Yet the end date for forecasts (' Fenddate ') cannot be found on the ''pred exo'' sheet of the Excel data file. Please verify that this sheet is properly filled, and remember that dates are case-sensitive.'];
            msgbox(message);
            error('programme termination: data error');
        end
        
        % identify the strings for the exogenous variables
        % loop over exogenous
        for ii=1:numexo
            % try to find a column match for exogenous variable ii
            [~,location]=find(strcmp(strngs,exo{ii,1}));
            % if no match is found, return an error
            if isempty(location)
                message=['Error: a forecast application is selected for a model that uses exogenous variables. Hence, predicted exogenous values should be supplied over the forecast periods. Yet the exogenous variable ''' exo{ii,1} ''' cannot be found on the ''pred exo'' sheet of the Excel data file. Please verify that this sheet is properly filled, and remember that variable names are case-sensitive.'];
                msgbox(message);
                error('programme termination: data error');
                % else, record the value
            else
                pexolocation(ii,1)=location;
            end
        end
        
        % if everything was fine, reconstitute the matrix data_exo_p
        % initiate
        data_exo_p=[];
        % loop over exogenous variables
        for ii=1:numexo
            % initiate the predicted values for exogenous variable ii
            predexo=[];
            % loop over forecast periods
            for jj=1:Fperiods
                temp=strngs{Fstartlocation+jj-1,pexolocation(ii,1)};
                % if this entry is empty or NaN, return an error
                if (isempty(temp) || (temp<=inf)==0)
                    message=['Error: the predicted value for exogenous variable ' exo{ii,1} ' at forecast period ' strngs{Fstartlocation+jj,1} ' (and possibly other entries) is either empty or NaN. Please verify that the ''pred exo'' sheet of the Excel data file is properly filled.'];
                    msgbox(message);
                    error('programme termination: data error');
                    % if this entry is a number, record it
                else
                    predexo=[predexo;temp];
                end
            end
            % concatenate
            data_exo_p=[data_exo_p predexo];
        end
        
        % also, record the exogenous values on Excel
        % replace NaN entries by blanks
        strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
        % then save on Excel
        if pref.results==1
            xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strngs,'pred exo','A1');
        end
    end
    
    
end
