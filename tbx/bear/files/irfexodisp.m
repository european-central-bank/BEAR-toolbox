function []=irfexodisp(n,m,endo,exo,IRFperiods,exo_irf_estimates,pref)




% IRFs

if pref.plot
    
% plot the figure
irf=figure;
set(irf,'Color',[0.9 0.9 0.9]);
set(irf,'name',['impulse response functions (exogenous)']);

% initiate the count
count=0;
% loop over variables
for ii=1:n
   % loop over exogenous (for shocks)
   for kk=2:m
   % increment count
   count=count+1;
   % then plot
   subplot(n,m,count)
   temp=exo_irf_estimates{ii,kk};
   hold on
   Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
   Ypatch=[temp(1,:) fliplr(temp(3,:))];
   IRFpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(IRFpatch,'facealpha',0.5);
   set(IRFpatch,'edgecolor','none');
   plot(temp(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
   plot([1,IRFperiods],[0 0],'k--');
   hold off
   minband=min(temp(1,:));
   maxband=max(temp(3,:));
   space=maxband-minband;
   Ymin=minband-0.2*space;
   Ymax=maxband+0.2*space;
   set(gca,'XLim',[1 IRFperiods],'YLim',[Ymin Ymax],'FontName','Times New Roman');
      % top labels
      title(exo{kk-1,1},'FontWeight','normal','interpreter','latex');
      % side labels
      ylabel([endo{ii,1}],'FontWeight','normal','interpreter','latex');
   end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal','interpreter','latex');
% side supertitle
ylabel('Response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal','interpreter','latex');
set(get(ax,'Ylabel'),'Visible','on');

end % pref.plot


% create the cell that will be saved on excel
exo_irfcell={};
% build preliminary elements: space between the tables
horzspace=repmat({''},2,5*m);
vertspace=repmat({''},IRFperiods+3,1);
% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:m
   % create cell of IRF record for variable ii in response to shock jj
      if jj==1
      temp=['response of ' endo{ii,1} ' to constant shocks'];
      else
      temp=['response of ' endo{ii,1} ' to ' exo{jj-1,1} ' shocks'];
      end
   irf_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};num2cell((1:IRFperiods)') num2cell((exo_irf_estimates{ii,jj})')];
   tempcell=[tempcell irf_ij vertspace];
   end
exo_irfcell=[exo_irfcell;horzspace;tempcell];
end

% trim
exo_irfcell=exo_irfcell(3:end,1:end-1);

% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],exo_irfcell,'exogenous IRFs','B2');
end

