function [Fstartlocation, Fperiods] = get_fcast_rng(datestrings,opts)

% preliminary tasks
% first, identify the date strings, and the variable strings
startdate=bear.utils.fixstring(opts.startdate);
enddate=bear.utils.fixstring(opts.enddate);

Fstartdate = bear.utils.fixstring(opts.Fstartdate);
Fenddate   = bear.utils.fixstring(opts.Fenddate);
Fendsmpl   = opts.Fendsmpl;
frequency  = opts.frequency;

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