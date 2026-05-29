function [decimaldates1,stringdates1]=genpdate(names,lags,frequency,startdate,enddate)

% generate cells of date strings and vector of dates converted into decimal numbers; used for plots
% outputs:  - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - cell 'stringdates1': date strings for the sample period
% inputs: - cell 'names': cell containing the excel spreadsheet labels (names and dates)
%          - integer 'lags': number of lags included in the model
%          - integer 'frequency': frequency of the data set
%          - string 'startdate': start date of the sample
%          - string 'enddate': end date of the sample

% preliminary tasks
% define date strings
datestrings=names(2:end,1);


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