function []=cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref)



% function []=cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,datapath)
% plots the results for conditional forecasts
% inputs:  - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - cell 'stringdates2': date strings for the sample+forecasts period
%          - vector 'decimaldates2': dates converted into decimal values, for the sample+forecasts period
%          - integer 'Fstartlocation': position of the forecast start date in stringdates2
%          - integer 'Fendlocation': position of the forecast end date in stringdates2
%          - cell 'cforecast_estimates': lower bound, point estimates, and upper bound for the conditional forecasts
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none




% first, create a cell that will store the data to be plot
cplotdata=cell(n,1);

% each cell entry is a matrix of actual and forecast values
% this matrix comprises 4 rows: the first row is actual data, while the three other rows are the estimates (point estimates and confidence bands) for the forecasts
% also, this matrix has a number of rows equal to the dimension of decimaldates2, which comprises the total period sample+forecasts

% loop over variables

for ii=1:n
   cplotdata{ii,1}=nan(4,size(decimaldates2,1));
   % record actual sample values
   cplotdata{ii,1}(1,1:T)=Y(:,ii)';
   % copy the last point of the actual sample for the forecast part of the matrix (required to have a clean plot)
   cplotdata{ii,1}(:,Fstartlocation-1)=repmat(Y(Fstartlocation-1,ii),4,1);
   % record forecast, lower bound
   cplotdata{ii,1}(2,Fstartlocation:Fendlocation)=cforecast_estimates{ii,1}(1,:);
   % record forecast, point estimate
   cplotdata{ii,1}(3,Fstartlocation:Fendlocation)=cforecast_estimates{ii,1}(2,:);
   % record forecast, upper bound
   cplotdata{ii,1}(4,Fstartlocation:Fendlocation)=cforecast_estimates{ii,1}(3,:);
end


if pref.plot

% create forecast figure
% then plot actual vs. fitted
forecast=figure;
set(forecast,'Color',[0.9 0.9 0.9]);
set(forecast,'name','conditional forecasts');
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
for ii=1:n
subplot(nrows,ncolumns,ii);
hold on
Xpatch=[decimaldates2(Fstartlocation-1:Fendlocation,1)' fliplr((decimaldates2(Fstartlocation-1:Fendlocation,1))')];
Ypatch=[cplotdata{ii,1}(2,Fstartlocation-1:Fendlocation) fliplr(cplotdata{ii,1}(4,Fstartlocation-1:Fendlocation))];
Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(Fpatch,'facealpha',0.6);
set(Fpatch,'edgecolor','none');
plot(decimaldates2,cplotdata{ii,1}(3,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot(decimaldates2,cplotdata{ii,1}(1,:),'Color',[0 0 0],'LineWidth',2);
hold off
set(gca,'XLim',[decimaldates2(1,1) decimaldates2(end,1)],'FontName','Times New Roman');
set(gca,'XGrid','on');
set(gca,'YGrid','on');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal');
end

end % pref.plot

% finally, save on excel
excelrecord8

