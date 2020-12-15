function[dataSLM,datesSLM,namesSLM]=loadSLM(names,data_endo,p)
T=size(data_endo,1)-p;
%first check for which variables the survey local mean is available and the read the local mean data
[dataSLM, namesSLM, rawSLM]=xlsread('data.xlsx','Survey Local Mean');
datesSLM = namesSLM(2:end,1); %get the datevector for the survey local mean
namesSLM = namesSLM(1,2:end); %and the corresponding names

isnan = strcmp('NaN', rawSLM(2:end,2:end)); 
firstnonnan = find(isnan(:,1)==0, 1, 'first');
lastnonnan  = find(isnan(:,1)==0, 1, 'last');
%first append dataSLM with missings, if the communcation between matlab and
%excel didnt work properly, causing matlab to read the data only from the
%first non nan onwards. 
if firstnonnan ~= 1
dataSLM = [nan(firstnonnan-1,size(dataSLM,2)); dataSLM];
end 

if lastnonnan ~= T+p
dataSLM  = [dataSLM; nan(T+p-lastnonnan,size(dataSLM,2)); ];    
end 
%dataSLM should now have the same dimensions as the datevector
if length(dataSLM) ~= length(datesSLM)
msgbox('SLM data and SLM dates do not coincide'); 
error('programme termination: date error'); 
end 

%now check if the datevectors coincide
datesendo=names(2:end,1);
indicator = ismember(datesSLM, datesendo);

if sum(indicator) ~= T+p
     firstcommonsample = find(indicator==1, 1, 'first');
     lastcommonsample =  find(indicator==1, 1, 'last');
     dataSLM = [nan(firstcommonsample-1,size(dataSLM,2)),dataSLM]; 
     dataSLM = [dataSLM, nan((size(datesendo,1)-lastcommonsample),size(dataSLM,2))];
end 


            

