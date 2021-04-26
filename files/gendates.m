function [decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation]=gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar)



% function [decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation]=gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F)
% generate cells of date strings and vector of dates converted into decimal numbers; used for plots
% inputs:  - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - vector 'decimaldates2': dates converted into decimal values, for the sample+forecasts period
%          - cell 'stringdates1': date strings for the sample period
%          - cell 'stringdates2': date strings for the sample+forecasts period
%          - cell 'stringdates3': date strings for the forecast evaluation period (i.e. period for which forecast is estimated and actual data exists)
%          - integer 'Fstartlocation': position of the forecast start date in stringdates2
%          - integer 'Fendlocation': position of the forecast end date in stringdates2
% outputs: - cell 'names': cell containing the excel spreadsheet labels (names and dates)
%          - integer 'lags': number of lags included in the model
%          - integer 'frequency': frequency of the data set
%          - string 'startdate': start date of the sample
%          - string 'enddate': end date of the sample
%          - string 'Fstartdate': start date of the forecasts
%          - string 'Fenddate': end date of the forecasts
%          - string 'Fcenddate': end date of the forecat evaluation (i.e. period for which forecast is estimated and actual data exists)
%          - integer 'Fendsmpl': 0-1 value to determine if forecasts must start after the final sample period
%          - integer 'F': 0-1 value to determine if forecasts must be estimated




% preliminary tasks
% define date strings
datestrings=names(2:end,1);

if favar.FAVAR==1 % in case we transform the data to first or second differences, we have a different startlocation
    if favar.transformation==1 
        datestrings=names(1+favar.informationstartlocation:favar.informationendlocation_sub,:); %first row are labels
    end
end

% PHASE 1: CREATION OF DECIMAL DATES AND DATE STRINGS FOR THE ESTIMATION SAMPLE (DECIMALDATES1, STRINGDATES1)


% deal first with the data if it is yearly
if frequency==1
% identify the number of years covered by the sample
startyear=str2num(startdate(1,1:end-1));
endyear=str2num(enddate(1,1:end-1));
% create the decimal value vector
decimaldates1=(startyear:endyear)';
% convert into strings
stringdates1=cellfun(@num2str,num2cell(decimaldates1),'UniformOutput',0);
% add a 'y' character at the end
for ii=1:size(stringdates1,1)
stringdates1{ii,1}=[stringdates1{ii,1} 'y'];
end
% trim a number of initial periods equal to the number of lags, as these periods will be used to create initial conditions
decimaldates1=decimaldates1(lags+1:end,:);
stringdates1=stringdates1(lags+1:end,:);

% deal now with the data if it is quarterly
elseif frequency==2
% first identify the year and quarter of the initial date
startyear=str2num(startdate(1,1:4));
startquarter=str2num(startdate(1,6));
% proceed similarly for the year and quarter of the final date
endyear=str2num(enddate(1,1:4));
endquarter=str2num(enddate(1,6));
% initiate the decimal value vector and the string cell
decimaldates1=[];
stringdates1={};
% create the decimal vector from start date up to the penultimate year
year=startyear;
quarter=startquarter;
   while year<=endyear-1
      while quarter<=4
      decimaldates1=[decimaldates1;year+(quarter-1)/4];
      temp=[num2str(year) 'q' num2str(quarter)];
      stringdates1{end+1,1}=temp;
      quarter=quarter+1;
      end
   quarter=1;
   year=year+1;
   end
% complete with final year  
   while quarter<=endquarter
   decimaldates1=[decimaldates1;year+(quarter-1)/4];
   temp=[num2str(year) 'q' num2str(quarter)];
   stringdates1{end+1,1}=temp;
   quarter=quarter+1;
   end
% finally, trim a number of initial periods equal to the number of lags, as these periods will be used to create initial conditions
decimaldates1=decimaldates1(lags+1:end,:);
stringdates1=stringdates1(lags+1:end,:);

% deal now with the data if it is monthly
elseif frequency==3
% first identify the year and month of the initial date
temp=startdate;
temp(1,5)=' ';
[startyear,startmonth]=strtok(temp);
startyear=str2num(startyear);
startmonth=str2num(startmonth);
% proceed similarly for the year and month of the final date
temp=enddate;
temp(1,5)=' ';
[endyear,endmonth]=strtok(temp);
endyear=str2num(endyear);
endmonth=str2num(endmonth);
% initiate the decimal value vector and the string cell
decimaldates1=[];
stringdates1={};
% create the decimal vector from start date up to the penultimate year
year=startyear;
month=startmonth;
   while year<=endyear-1
      while month<=12
      decimaldates1=[decimaldates1;year+(month-1)/12];
      temp=[num2str(year) 'm' num2str(month)];
      stringdates1{end+1,1}=temp;
      month=month+1;
      end
   month=1;
   year=year+1;
   end
% complete with final year  
   while month<=endmonth
   decimaldates1=[decimaldates1;year+(month-1)/12];
   temp=[num2str(year) 'm' num2str(month)];
   stringdates1{end+1,1}=temp;
   month=month+1;
   end
% finally, trim a number of initial periods equal to the number of lags, as these periods will be used to create initial conditions
decimaldates1=decimaldates1(lags+1:end,:);
stringdates1=stringdates1(lags+1:end,:);

% deal now with the data if it is weekly
elseif frequency==4
% first identify the first and last years of the sample
startyear=str2num(startdate(1,1:4));
endyear=str2num(enddate(1,1:4));
% calculate the total number of years over the period
numyear=endyear-startyear+1;
% create a vector of date strings for the sample period
start=find(strcmp(datestrings,startdate));
finish=find(strcmp(datestrings,enddate));
stringdates1=datestrings(start:finish,1);
% for each year in the sample, identify the earliest and latest week 
   for ii=startyear:endyear
   % first identify which periods in the sample correspond to this year
   periods=strfind(stringdates1,num2str(ii));
      for jj=1:size(periods,1)
         if isempty(periods{jj,1})
         periods{jj,1}=0;
         end
      end
      periods=cell2mat(periods);
   % identify the position of the first week and the last week of this year
   first=min(find(periods==1));
   last=max(find(periods==1));
   % identify the week number to which these positions correspond
   temp=char(stringdates1(first,1));
   temp(1,5)=' ';
   [~,weeknum]=strtok(temp);
   week(ii-startyear+1,1)=str2num(weeknum);
   temp=char(stringdates1(last,1));
   temp(1,5)=' ';
   [~,weeknum]=strtok(temp);
   week(ii-startyear+1,2)=str2num(weeknum);
   end
% now create the vector of decimal data
decimaldates1=[];
% compute until penultimate year
   for ii=1:numyear-1
      for jj=week(ii,1):week(ii,2)
      decimaldates1=[decimaldates1;(startyear+ii-1)+((jj-1)/week(ii,2))];
      end
   end
% compute for last year (assuming a year of 52 weeks if the number of weeks is shorter)
   if week(numyear,2)<52
   total=52;
   else
   total=week(numyear,2);
   end
   for jj=week(numyear,1):week(numyear,2)
   decimaldates1=[decimaldates1;endyear+((jj-1)/total)];
   end
% finally, trim a number of initial periods equal to the number of lags, as these periods will be used to create initial conditions
decimaldates1=decimaldates1(lags+1:end,:);
stringdates1=stringdates1(lags+1:end,:);

% deal now with the data if it is daily
elseif frequency==5
% first identify the first and last years of the sample
startyear=str2num(startdate(1,1:4));
endyear=str2num(enddate(1,1:4));
% calculate the total number of years over the period
numyear=endyear-startyear+1;
% create a vector of date strings for the sample period
start=find(strcmp(datestrings,startdate));
finish=find(strcmp(datestrings,enddate));
stringdates1=datestrings(start:finish,1);
% for each year in the sample, identify the earliest and latest day 
   for ii=startyear:endyear
   % first identify which periods in the sample correspond to this year
   periods=strfind(stringdates1,num2str(ii));
      for jj=1:size(periods,1)
         if isempty(periods{jj,1})
         periods{jj,1}=0;
         end
      end
      periods=cell2mat(periods);
   % identify the position of the first day and the last day of this year
   first=min(find(periods==1));
   last=max(find(periods==1));
   % indentify the day number to which these positions correspond
   temp=char(stringdates1(first,1));
   temp(1,5)=' ';
   [~,daynum]=strtok(temp);
   day(ii-startyear+1,1)=str2num(daynum);
   temp=char(stringdates1(last,1));
   temp(1,5)=' ';
   [~,daynum]=strtok(temp);
   day(ii-startyear+1,2)=str2num(daynum);
   end
% now create the vector of decimal data
decimaldates1=[];
% compute until penultimate year
   for ii=1:numyear-1
      for jj=day(ii,1):day(ii,2)
      decimaldates1=[decimaldates1;(startyear+ii-1)+((jj-1)/day(ii,2))];
      end
   end
% compute for last year (assuming a working year of 5 days a week, i.e. 261 opening days a year, if the total number of day is shorter)
   if day(numyear,2)<261
   total=261;
   else
   total=day(numyear,2);
   end
   for jj=day(numyear,1):day(numyear,2)
   decimaldates1=[decimaldates1;endyear+((jj-1)/total)];
   end
% finally, trim a number of initial periods equal to the number of lags, as these periods will be used to create initial conditions
decimaldates1=decimaldates1(lags+1:end,:);
stringdates1=stringdates1(lags+1:end,:);

% finally, if the data is undated
elseif frequency==6
% identify the number of periods covered by the sample
startperiod=str2num(startdate(1,1:end-1));
endperiod=str2num(enddate(1,1:end-1));
% create the decimal value vector
decimaldates1=(startperiod:endperiod)';
% convert into strings
stringdates1=cellfun(@num2str,num2cell(decimaldates1),'UniformOutput',0);
% add a 'u' character at the end
for ii=1:size(stringdates1,1)
stringdates1{ii,1}=[stringdates1{ii,1} 'u'];
end
% trim a number of initial periods equal to the number of lags, as these periods will be used to create initial conditions
decimaldates1=decimaldates1(lags+1:end,:);
stringdates1=stringdates1(lags+1:end,:);
end






% from now on, the code applies only if forecasts have been selected
% if not, simply return empty matrices

if F==0 && CF==0
decimaldates2=[];
stringdates2=[];
Fstartlocation=[];
Fendlocation=[];
stringdates3=[];
else





   % PHASE 2: CREATION OF DECIMAL DATES FOR THE FORECAST PERIOD (DECIMALDATES2)

   % determine first whether the final forecast period is included or not in the sample
   % first deal with data if it is yearly
   if frequency==1
   % simply check wether the sample end year is anterior to the forecast end year
      if str2num(enddate(1,1:end-1))<str2num(Fenddate(1,1:end-1))
      included=0;
      else
      included=1;
      end
   % if data is quarterly
   elseif frequency==2
   % first identify the year and quarter of the final sample date
   smplendyear=str2num(enddate(1,1:4));
   smplendquarter=str2num(enddate(1,6));
   % similarly, identify the year and quarter of the final forecast date
   Fendyear=str2num(Fenddate(1,1:4));
   Fendquarter=str2num(Fenddate(1,6));
      if smplendyear<Fendyear
      included=0;
      elseif smplendyear==Fendyear && smplendquarter<Fendquarter
      included=0;
      else
      included=1;
      end
   % if data is monthly
   elseif frequency==3
   % first identify the year and month of the final sample date
   temp=enddate;
   temp(1,5)=' ';
   [smplendyear,smplendmonth]=strtok(temp);
   smplendyear=str2num(smplendyear);
   smplendmonth=str2num(smplendmonth);
   % identify the year and month of the final forecast date
   temp=Fenddate;
   temp(1,5)=' ';
   [Fendyear,Fendmonth]=strtok(temp);
   Fendyear=str2num(Fendyear);
   Fendmonth=str2num(Fendmonth);
      if smplendyear<Fendyear
      included=0;
      elseif smplendyear==Fendyear && smplendmonth<Fendmonth
      included=0;
      else
      included=1;
      end
   % if data is weekly
   elseif frequency==4
   % first identify the year and week of the final sample date
   temp=enddate;
   temp(1,5)=' ';
   [smplendyear,smplendweek]=strtok(temp);
   smplendyear=str2num(smplendyear);
   smplendweek=str2num(smplendweek);
   % identify the year and week of the final forecast date
   temp=Fenddate;
   temp(1,5)=' ';
   [Fendyear,Fendweek]=strtok(temp);
   Fendyear=str2num(Fendyear);
   Fendweek=str2num(Fendweek);
      if smplendyear<Fendyear
      included=0;
      elseif smplendyear==Fendyear && smplendweek<Fendweek
      included=0;
      else
      included=1;
      end
   % if data is daily
   elseif frequency==5
   % first identify the year and day of the final sample date
   temp=enddate;
   temp(1,5)=' ';
   [smplendyear,smplendday]=strtok(temp);
   smplendyear=str2num(smplendyear);
   smplendday=str2num(smplendday);
   % identify the year and day of the final forecast date
   temp=Fenddate;
   temp(1,5)=' ';
   [Fendyear,Fendday]=strtok(temp);
   Fendyear=str2num(Fendyear);
   Fendday=str2num(Fendday);
      if smplendyear<Fendyear
      included=0;
      elseif smplendyear==Fendyear && smplendday<Fendday
      included=0;
      else
      included=1;
      end
   % finally, if data is undated
   elseif frequency==6
   % simply check wether the sample end period is anterior to the forecast end period
      if str2num(enddate(1,1:end-1))<str2num(Fenddate(1,1:end-1))
      included=0;
      else
      included=1;
      end
   end





   % if the final forecast period is included in the sample, simply define decimaldates2 as decimaldates1
   if included==1
   decimaldates2=decimaldates1;
   stringdates2=stringdates1;


   % if the final forecast period lies beyond the end of the sample, define a new vector of decimal dates running from the sample start until the last forecast period
   elseif included==0
   % deal first with the data if it is yearly
      if frequency==1
      % simply complete decimaldates1 up to the final forecast period
      decimaldates2=[decimaldates1;(decimaldates1(end,1)+1:str2num(Fenddate(1,1:end-1)))'];
      stringdates2=cellfun(@num2str,num2cell(decimaldates2),'UniformOutput',0);
      % add a 'y' character at the end
      for ii=1:size(stringdates2,1)
      stringdates2{ii,1}=[stringdates2{ii,1} 'y'];
      end

   % if the data is quarterly
      elseif frequency==2
      % initiate the series
      decimaldates2=decimaldates1;
      stringdates2=stringdates1;
      % identify the year and quarter of the last sample period
      endyear=str2num(enddate(1,1:4));
      endquarter=str2num(enddate(1,6));
      % identify the year and quarter of the last forecast period
      Fendyear=str2num(Fenddate(1,1:4));
      Fendquarter=str2num(Fenddate(1,6));
      % advance sample end by one period
      year=endyear;
      quarter=endquarter;
         if quarter<4
         quarter=quarter+1;
         elseif quarter==4
         year=year+1;
         quarter=1;
         end
         while year<=Fendyear-1
            while quarter<=4
            decimaldates2=[decimaldates2;year+(quarter-1)/4];
            temp=[num2str(year) 'q' num2str(quarter)];
            stringdates2{end+1,1}=temp;
            quarter=quarter+1;
            end
         quarter=1;
         year=year+1;
         end
         % complete with final year  
         while quarter<=Fendquarter
         decimaldates2=[decimaldates2;year+(quarter-1)/4];
         temp=[num2str(year) 'q' num2str(quarter)];
         stringdates2{end+1,1}=temp;
         quarter=quarter+1;
         end

   % if the data is monthly
      elseif frequency==3
      % initiate the series
      decimaldates2=decimaldates1;
      stringdates2=stringdates1;
      % identify the year and month of the last sample period
      temp=enddate;
      temp(1,5)=' ';
      [endyear,endmonth]=strtok(temp);
      endyear=str2num(endyear);
      endmonth=str2num(endmonth);
      % identify the year and month of the last forecast period
      temp=Fenddate;
      temp(1,5)=' ';
      [Fendyear,Fendmonth]=strtok(temp);
      Fendyear=str2num(Fendyear);
      Fendmonth=str2num(Fendmonth);
      % advance sample end by one period
      year=endyear;
      month=endmonth;
         if month<12
         month=month+1;
         elseif month==12
         year=year+1;
         month=1;
         end
         while year<=Fendyear-1
            while month<=12
            decimaldates2=[decimaldates2;year+(month-1)/12];
            temp=[num2str(year) 'm' num2str(month)];
            stringdates2{end+1,1}=temp;
            month=month+1;
            end
         month=1;
         year=year+1;
         end
         % complete with final year  
         while month<=Fendmonth
         decimaldates2=[decimaldates2;year+(month-1)/12];
         temp=[num2str(year) 'm' num2str(month)];
         stringdates2{end+1,1}=temp;
        month=month+1;
         end

   % if the data is weekly
      elseif frequency==4
      % first identify the year and week of the final forecast date
      temp=Fenddate;
      temp(1,5)=' ';
      [Fendyear,Fendweek]=strtok(temp);
      Fendyear=str2num(Fendyear);
      Fendweek=str2num(Fendweek);
      % identify the year and week of the final data set date
      temp=datestrings{end,1};
      temp(1,5)=' ';
      [dataendyear,dataendweek]=strtok(temp);
      dataendyear=str2num(dataendyear);
      dataendweek=str2num(dataendweek);
      % now, there are two possibilities: either the forecast period is entirely included in the dataset, or it goes beyond the dataset
         % if entirely included in the dataset
         if Fendyear<dataendyear || (Fendyear==dataendyear && Fendweek<dataendweek)
         % then just copy the date strings from sample start to forecast end
         % find position for sample start
         start=find(cellfun(@isempty,strfind(datestrings,startdate))==0);
         % find position for forecast end
         finish=find(cellfun(@isempty,strfind(datestrings,Fenddate))==0);
         % create the strings
         stringdates2=datestrings(start:finish,1);
         % if the forecast periods goes beyond the data set
         else
         % find position for sample start
         start=find(cellfun(@isempty,strfind(datestrings,startdate))==0);
         % copy the dataset from sample start to its end
         stringdates2=datestrings(start:end,1);
         % advance the end of the dataset by one period
            if dataendweek<52
            year=dataendyear;
            week=dataendweek+1;
            else
            year=dataendyear+1;
            week=1;
            end
            % now complete stringdates2
            for ii=dataendyear:Fendyear-1
               while week<=52
               stringdates2{end+1,1}=[num2str(year) 'w' num2str(week)];
               week=week+1;
               end
            week=1;
            year=year+1;
            end
            % complete for the final year
            while week<=Fendweek
            stringdates2{end+1,1}=[num2str(year) 'w' num2str(week)];
            week=week+1;
            end
         end
      % finally, trim a number of initial conditions equal to the number of lags
      stringdates2=stringdates2(lags+1:end,1);
      % now that the strings are obtained, use them to generate the decimal dates
      % for each year in stringdates2, identify the number of weeks
      maxweek=zeros(size(stringdates2,1),1);
         for ii=str2num(startdate(1,1:4)):Fendyear-1
         periods=strfind(stringdates2,num2str(ii));
            for jj=1:size(periods,1)
               if isempty(periods{jj,1})
               periods{jj,1}=0;
               end
            end
         periods=cell2mat(periods);
         location=max(find(periods==1));
         temp=char(stringdates2(location,1));
         temp(1,5)=' ';
         [~,weeknum]=strtok(temp);
         maxweek=maxweek+periods*str2num(weeknum);
         end
      % complete for the final year
      periods=strfind(stringdates2,num2str(Fendyear));
         for jj=1:size(periods,1)
            if isempty(periods{jj,1})
            periods{jj,1}=0;
            end
         end
      periods=cell2mat(periods);
      maxweek=maxweek+periods*max(52,Fendweek);
      % finally, compute the decimal dates
         for ii=1:size(stringdates2,1)
         temp=stringdates2{ii,1};
         temp(1,5)=' ';
         [~,weeknum]=strtok(temp);
         decimaldates2(ii,1)=str2num(temp(1,1:4))+str2num(weeknum)/maxweek(ii,1);
         end

   % if the data is daily
      elseif frequency==5
      % first identify the year and day of the final forecast date
      temp=Fenddate;
      temp(1,5)=' ';
      [Fendyear,Fendday]=strtok(temp);
      Fendyear=str2num(Fendyear);
      Fendday=str2num(Fendday);
      % identify the year and day of the final data set date
      temp=datestrings{end,1};
      temp(1,5)=' ';
      [dataendyear,dataendday]=strtok(temp);
      dataendyear=str2num(dataendyear);
      dataendday=str2num(dataendday);
      % now, there are two possibilities: either the forecast period is entirely included in the dataset, or it goes beyond the dataset
         % if entirely included in the dataset
         if Fendyear<dataendyear || (Fendyear==dataendyear && Fendday<dataendday)
         % then just copy the date strings from sample start to forecast end
         % find position for sample start
         start=find(cellfun(@isempty,strfind(datestrings,startdate))==0);
         % find position for forecast end
         finish=find(cellfun(@isempty,strfind(datestrings,Fenddate))==0);
         % create the strings
         stringdates2=datestrings(start:finish,1);
         % if the forecast periods goes beyond the data set
         else
         % find position for sample start
         start=find(cellfun(@isempty,strfind(datestrings,startdate))==0);
         % copy the dataset from sample start to its end
         stringdates2=datestrings(start:end,1);
         % advance the day of the dataset by one period
            if dataendday<261
            year=dataendyear;
            day=dataendday+1;
            else
            year=dataendyear+1;
            day=1;
            end
            % now complete stringdates2
            for ii=dataendyear:Fendyear-1
               while day<=261
               stringdates2{end+1,1}=[num2str(year) 'd' num2str(day)];
               day=day+1;
               end
            day=1;
            year=year+1;
            end
            % complete for the final year
            while day<=Fendday
            stringdates2{end+1,1}=[num2str(year) 'd' num2str(day)];
            day=day+1;
            end
         end
      % finally, trim a number of initial conditions equal to the number of lags
      stringdates2=stringdates2(lags+1:end,1);
      % now that the strings are obtained, use them to generate the decimal dates
      % for each year in stringdates2, identify the number of day
      maxday=zeros(size(stringdates2,1),1);
         for ii=str2num(startdate(1,1:4)):Fendyear-1
         periods=strfind(stringdates2,num2str(ii));
            for jj=1:size(periods,1)
               if isempty(periods{jj,1})
               periods{jj,1}=0;
               end
            end
         periods=cell2mat(periods);
         location=max(find(periods==1));
         temp=char(stringdates2(location,1));
         temp(1,5)=' ';
         [~,daynum]=strtok(temp);
         maxday=maxday+periods*str2num(daynum);
         end
      % complete for the final year
      periods=strfind(stringdates2,num2str(Fendyear));
         for jj=1:size(periods,1)
            if isempty(periods{jj,1})
            periods{jj,1}=0;
            end
         end
      periods=cell2mat(periods);
      maxday=maxday+periods*max(261,Fendday);
      % finally, compute the decimal dates
         for ii=1:size(stringdates2,1)
         temp=stringdates2{ii,1};
         temp(1,5)=' ';
         [~,daynum]=strtok(temp);
         decimaldates2(ii,1)=str2num(temp(1,1:4))+str2num(daynum)/maxday(ii,1);
         end

   % finally, if the data is undated
      elseif frequency==6
      % simply complete decimaldates1 up to the final forecast period
      decimaldates2=[decimaldates1;(decimaldates1(end,1)+1:str2num(Fenddate(1,1:end-1)))'];
      stringdates2=cellfun(@num2str,num2cell(decimaldates2),'UniformOutput',0);
         % add a 'u' character at the end
         for ii=1:size(stringdates2,1)
         stringdates2{ii,1}=[stringdates2{ii,1} 'u'];
         end
      end
   end







   % PHASE 3: IDENTIFICATION OF THE POSITION OF THE INITIAL FORECAST PERIOD (IN TERMS OF THE VECTOR DECIMALDATES2)

   % identify the position of the start period for the forecasts
   % if the start period has been selected as the first period after the sample end, identifies it directly
   if Fendsmpl==1
   Fstartlocation=size(stringdates1,1)+1;
   % if the start period has not been selected as the first period after the sample end, it must be within the sample: look for it
   elseif Fendsmpl==0
   Fstartlocation=find(strcmp(stringdates1,Fstartdate));
   end

   % identify the position of the end period for the forecasts
   % if the end period is included in the sample, it can be identified directly
   if included==1
   Fendlocation=find(strcmp(stringdates1,Fenddate));
   % if the end period is beyond the sample, then its position is simply the last period of datestrings2
   elseif included==0
   Fendlocation=size(stringdates2,1);
   end


   
   
   
   % PHASE 3: CREATION OF DATE STRINGS FOR THE COMMON PERIOD
   
   
   % these date strings will be used only at one point: for the display of forecast evaluation
   % to identify the strings, simply copy from datestrings2 the dates over the common forecast period
   startfcperiod=find(strcmp(stringdates2,Fstartdate));
   endfcperiod=find(strcmp(stringdates2,Fcenddate));
   stringdates3=stringdates2(startfcperiod:endfcperiod,1);
   
   
   


end


