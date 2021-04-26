function []=ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,pref)



% function []=ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,datapath)
% creates a plot for actual and steady-state values

% inputs:  - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8) 
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - cell 'stringdates1': date strings for the sample period
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - cell 'ss_estimates': lower bound, point estimates, and upper bound for the steady-state
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none


if pref.plot==1
% create steady-state figure
sstate=figure;
set(sstate,'Color',[0.9 0.9 0.9]);
set(sstate,'name','steady-state');
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
for ii=1:n
subplot(nrows,ncolumns,ii);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[ss_estimates{ii,1}(1,:) fliplr(ss_estimates{ii,1}(3,:))];
Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(Fpatch,'facealpha',0.6);
set(Fpatch,'edgecolor','none');
ss=plot(decimaldates1,ss_estimates{ii,1}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
actual=plot(decimaldates1,Y(:,ii),'Color',[0 0 0],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
% % % if m>1
% % % hold on
% % % plot(decimaldates1(1,1),ss_estimates_constant{ii,1}(2,:),'Color',[1 0.4 1],'LineWidth',2);
% % % hold on
% % % plot(decimaldates1(1,1),ss_estimates_contribution_exo{ii,1}(1,:),'Color',[1 1 1],'LineWidth',2);
% % % end
hold off
minband=min(min(ss_estimates{ii,1}(1,:)),min(Y(:,ii)));
maxband=max(max(ss_estimates{ii,1}(3,:)),max(Y(:,ii)));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin,Ymax],'FontName','Times New Roman');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal','interpreter','latex');
   if ii==1
   plotlegend=legend([ss,actual],'steady-state','actual');
   set(plotlegend,'FontName','Times New Roman');
   end
end

end %pref.plot

% finally, record the results on excel
excelrecord3


