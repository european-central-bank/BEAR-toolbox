function []=hddisp(n,endo,Y,decimaldates1,hd_estimates,stringdates1,T,pref,IRFt,signreslabels,Fstartlocation)



% function []=hddisp(n,endo,decimaldates1,hd_estimates,stringdates1,T,datapath)
% plots the results for the historical decomposition
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - cell 'hd_estimates': lower bound, point estimates, and upper bound for the historical decomposition
%          - cell 'stringdates1': date strings for the sample period
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none



% transpose the cell of records (required for the plot function in order to obtain correctly ordered plots)
hd_estimates=hd_estimates';

% loop over all shocks for all endogenous variables
for ii=1:n*(n+1)
% positive and negative distributions are calculated seperately for
% graphical Matlab issues
contributions(:,ii)=[hd_estimates{ii}(2,:)'];
contribpos(:,ii)=contributions(:,ii);
contribpos(contribpos<0)=0;
contribneg(:,ii)=contributions(:,ii);
contribneg(contribneg>0)=0;
end

% calculate the sum of all contributions to proxy the actual development of
% the endogenous variable

Total = zeros(length(decimaldates1),n);
for i=1:n
    Total(:,i) = sum(contributions(:,(n+1)*(i-1)+1:(n+1)*i-1)');
end


% Colors
myC= [0 0 1
1 1 0
1 0.4 0
0 0.8 1
0 1 0
1 0 1
0 1 1
1 0.2 0.5
0.7 1 0.7
0.7 0.7 1
0.8 0.3 0.6
0.3 0.8 0.6
0.4 0.7 0.8
];


if pref.plot
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
hd1=figure;
for i=1:n
set(hd1,'name','Historical decomposition');
subplot(nrows,ncolumns,i)
hdpos=bar(decimaldates1, contribpos(:,n*(i-1)+i:(n+1)*i-1), 0.8, 'stacked');
hold on
hdneg=bar(decimaldates1, contribneg(:,n*(i-1)+i:(n+1)*i-1), 0.8, 'stacked');
hold on
plot(decimaldates1,Total(:,i),'k','LineWidth',2.8);
hold on
for k=1:n
    set(hdpos(k),'facecolor', myC(k,:), 'Edgecolor', 'none');
    set(hdneg(k),'facecolor', myC(k,:), 'Edgecolor', 'none');
end
if nargin==11
   yy=get(gca,'YLim');
   Xpatch=[ones(1,2)*decimaldates1(Fstartlocation) ones(1,2)*decimaldates1(T)];
   Ypatch=[yy fliplr(yy)];
   FHDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(FHDpatch,'facealpha',0.2);
   set(FHDpatch,'edgecolor','k','linewidth',0.1);
end
axis tight
hold off
% label the endogenous variables
title(endo{i,1})
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
%box off
end
if IRFt==4
   legend(signreslabels,'Location','Northoutside','Orientation','Vertical')
else
   legend(endo);
end
legend boxoff
end % pref.plot


% finally, record results in excel
% retranspose the cell of records
hd_estimates=hd_estimates';
excelrecord7