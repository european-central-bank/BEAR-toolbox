function []=panel2fevddisp(n,endo,fevd_estimates,IRFperiods,pref)










if pref.plot
% plot the figure
fevd=figure;
set(fevd,'Color',[0.9 0.9 0.9]);
set(fevd,'name','forecast error variance decomposition');
% initiate the count
count=0;
% loop over endogenous variables
for ii=1:n
   % loop over shocks
   for jj=1:n
   % increment count
   count=count+1;
   % then plot
   subplot(n,n,count)
   temp=fevd_estimates{ii,jj};
   hold on
   Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
   Ypatch=[temp(1,:) fliplr(temp(3,:))];
   FEVDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(FEVDpatch,'facealpha',0.5);
   set(FEVDpatch,'edgecolor','none');
   plot(temp(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
   hold off
   set(gca,'XLim',[1 IRFperiods],'YLim',[0 1],'FontName','Times New Roman');
      % top labels
      if count<=n
      title(endo{count,1},'FontWeight','normal');
      end
      % side labels
      if jj==1
      ylabel(endo{ii,1},'FontWeight','normal');
      end
   end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Contribution of shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
% side supertitle
ylabel('Variance of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
set(get(ax,'Ylabel'),'Visible','on');
end



% save on Excel
% create the cell that will be saved on excel
fevdcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},IRFperiods+3,1);
horzspace=repmat({''},3,5*n);
% loop over endogenous variables
for ii=1:n
% initiate the cell of results
endocell={};
   % loop over shocks
   for jj=1:n
   % create a header
   header=[{['part of ' endo{ii,1} ' fluctuation due to ' endo{jj,1} ' shocks']} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
   % complete the cell
   tempcell=[[header;num2cell((1:IRFperiods)') num2cell((fevd_estimates{ii,jj})')] vertspace];
   % concatenate to the previous parts of unitcell
   endocell=[endocell tempcell];
   end
% concatenate to the previous parts of irfcell
fevdcell=[fevdcell;horzspace;endocell];
end
% trim
fevdcell=fevdcell(4:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],fevdcell,'FEVD','B2');
end


