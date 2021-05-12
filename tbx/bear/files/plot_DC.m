[data]=xlsread('LRP.xls');
datevector=[1972:0.25:2014.75]';
subplot(2,2,1)
plot(datevector,data(:,4),'r--','LineWidth',0.5);
hold on
plot(datevector,data(:,5),'r','LineWidth',2.5);
hold on
plot(datevector,data(:,6),'r--','LineWidth',0.5);
hold on
plot(datevector,data(:,13),'b--','LineWidth',0.5);
hold on
plot(datevector,data(:,14),'b','LineWidth',2.5);
hold on
plot(datevector,data(:,15),'b--','LineWidth',0.5);
hold on
plot(datevector,data(:,1),'k','LineWidth',2.8);
hold off
% label the endogenous variables
axis tight
title('log GDP')
box off
subplot(2,2,2)
plot(datevector,data(:,7),'r--','LineWidth',0.5);
hold on
plot(datevector,data(:,8),'r','LineWidth',2.5);
hold on
plot(datevector,data(:,9),'r--','LineWidth',0.5);
hold on
plot(datevector,data(:,16),'b--','LineWidth',0.5);
hold on
plot(datevector,data(:,17),'b','LineWidth',2.5);
hold on
plot(datevector,data(:,18),'b--','LineWidth',0.5);
hold on
plot(datevector,data(:,2),'k','LineWidth',2.8);
hold off
% label the endogenous variables
axis tight
title('Inflation')
%set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
box off
subplot(2,2,3)
plot(datevector,data(:,10),'r--','LineWidth',0.5);
hold on
h1=plot(datevector,data(:,11),'r','LineWidth',2.5);
hold on
plot(datevector,data(:,12),'r--','LineWidth',0.5);
hold on
plot(datevector,data(:,19),'b--','LineWidth',0.5);
hold on
h2=plot(datevector,data(:,20),'b','LineWidth',2.5);
hold on
plot(datevector,data(:,21),'b--','LineWidth',0.5);
hold on
h3=plot(datevector,data(:,3),'k','LineWidth',2.8);
hold off
% label the endogenous variables
axis tight
title('Effective Federal Funds Rate')
legend([h1 h2 h3],{'Prior for the long run','Normal Wishart prior','Actual data'});
box off



ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
dcNW=figure;
for i=1:n;
set(dcNW,'name','Deterministic component');
subplot(nrows,ncolumns,i)
plot(decimaldates1,median(hd_record{n^2+i}),'r','LineWidth',2.8);
hold on
plot(decimaldates1,quantile(hd_record{n^2+i},0.16),'b--','LineWidth',1.8);
hold on
plot(decimaldates1,quantile(hd_record{n^2+i},0.84),'b--','LineWidth',1.8);
hold on
plot(decimaldates1,data_endo(5:end,i),'k','LineWidth',1.8);
hold off
% label the endogenous variables
axis tight
title(endo{i,1})
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
box off
end

