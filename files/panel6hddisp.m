function []=panel6hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref)








% plot the figure
if pref.plot
hd=figure;
set(hd,'Color',[0.9 0.9 0.9]);
set(hd,'name','historical decomposition');
% initiate the count
count=0;
% loop over units
for ii=1:N
   % loop over endogenous variables
   for jj=1:n
      % loop over units (for shocks)
      for kk=1:N
         % loop over shocks
         for ll=1:n
         % increment count
         count=count+1;
         % then plot
         subplot(N*n,N*n+1,count)
         temp=hd_estimates{(ii-1)*n+jj,(kk-1)*n+ll};
         hold on
         Xpatch=[decimaldates1' fliplr(decimaldates1')];
         Ypatch=[temp(1,:) fliplr(temp(3,:))];
         HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
         set(HDpatch,'facealpha',0.5);
         set(HDpatch,'edgecolor','none');
         plot(decimaldates1,temp(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
         plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
         hold off
         set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
            % top labels
            if (ii==1 && jj==1)
            title([Units{kk,1} '\_' endo{ll,1}],'FontWeight','normal');
            end
            % side labels
            if (kk==1 && ll==1)
            ylabel([Units{ii,1} '\_' endo{jj,1}],'FontWeight','normal');
            end
         end
      end
   % consider exogenous
   % increment count
   count=count+1;
   % then plot
   subplot(N*n,N*n+1,count)
   temp=hd_estimates{(ii-1)*n+jj,end};
   hold on
   Xpatch=[decimaldates1' fliplr(decimaldates1')];
   Ypatch=[temp(1,:) fliplr(temp(3,:))];
   HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(HDpatch,'facealpha',0.5);
   set(HDpatch,'edgecolor','none');
   plot(decimaldates1,temp(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
   plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
   hold off
   set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
      % top labels
      if (ii==1 && jj==1)
      title('Exogenous','FontWeight','normal');
      end
   end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Contribution of shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
% side supertitle
ylabel('Fluctuation of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
set(get(ax,'Ylabel'),'Visible','on')
end



% save on Excel

% create the cell that will be saved on excel
hdcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);
horzspace=repmat({''},2,5*(N*n+1)+N);
% loop over units
for ii=1:N
   % loop over endogenous variables
   for jj=1:n
   % initiate the cell of results
   rowcell={};
      % loop over units (for shocks)
      for kk=1:N
      endocell={};
         % loop over shocks
         for ll=1:n
         % create a header
         header=[{['fluctuation of ' Units{ii,1} '_' endo{jj,1} ' due to ' Units{kk,1} '_' endo{ll,1} ' shocks']} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
         % complete the cell
         tempcell=[[header;stringdates1 num2cell((hd_estimates{(ii-1)*n+jj,(kk-1)*n+ll})')] vertspace];
         % concatenate to the previous parts of unitcell
         endocell=[endocell tempcell];
         end
      rowcell=[rowcell vertspace endocell];
      end
   % exogenous contribution
   % create a header
   header=[{['fluctuation of ' Units{ii,1} '_' endo{jj,1} ' due to exogenous']} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
   % complete the cell
   tempcell=[[header;stringdates1 num2cell((hd_estimates{(ii-1)*n+jj,end})')]];
   % concatenate to the previous parts of rowcell
   rowcell=[rowcell vertspace tempcell];
   % concatenate to the previous parts of irfcell
   hdcell=[hdcell;horzspace;rowcell];
   end
hdcell=[hdcell;horzspace];
end
% trim
hdcell=hdcell(3:end-2,2:end);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],hdcell,'hist decomposition','B2');
end





