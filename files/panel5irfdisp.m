function []=panel5irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref)









% IRFs

% plot the figure
if pref.plot
irf=figure;
set(irf,'Color',[0.9 0.9 0.9]);
   if IRFt==1
   set(irf,'name',['impulse response functions (no structural identifcation)']);
   elseif IRFt==2
   set(irf,'name',['impulse response functions (structural identification by Choleski ordering)']);
   elseif IRFt==3
   set(irf,'name',['impulse response functions (structural identification by triangular factorisation)']);
   end
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
         subplot(N*n,N*n,count)
         temp=irf_estimates{(ii-1)*n+jj,(kk-1)*n+ll};
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
            if (ii==1 && jj==1)
            title([Units{kk,1} '\_' endo{ll,1}],'FontWeight','normal');
            end
            % side labels
            if (kk==1 && ll==1)
            ylabel([Units{ii,1} '\_' endo{jj,1}],'FontWeight','normal');
            end
         end
      end
   end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
% side supertitle
ylabel('Response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
set(get(ax,'Ylabel'),'Visible','on');
end
% save on Excel
% create the cell that will be saved on excel
irfcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},IRFperiods+3,1);
horzspace=repmat({''},2,5*N*n+N);
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
         header=[{['response of ' Units{ii,1} '_' endo{jj,1} ' to ' Units{kk,1} '_' endo{ll,1} ' shocks']} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
         % complete the cell
         tempcell=[[header;num2cell((1:IRFperiods)') num2cell((irf_estimates{(ii-1)*n+jj,(kk-1)*n+ll})')] vertspace];
         % concatenate to the previous parts of unitcell
         endocell=[endocell tempcell];
         end
      rowcell=[rowcell vertspace endocell];
      end
   % concatenate to the previous parts of irfcell
   irfcell=[irfcell;horzspace;rowcell];
   end
irfcell=[irfcell;horzspace];
end
% trim
irfcell=irfcell(3:end-2,2:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],irfcell,'IRF','B2');
end



% structural shocks

% generate plot, if there is any structural decomposition
if IRFt~=1
    if pref.plot
% plot
if pref.plot
strshocks=figure;
set(strshocks,'Color',[0.9 0.9 0.9]);
set(strshocks,'name','structural shocks')
% initiate the count
count=0;
   % loop over units
   for ii=1:N
      % loop over endogenous variables
      for jj=1:n
      % increment count
      count=count+1;
      % then plot
      subplot(N,n,count)
      hold on
      Xpatch=[decimaldates1' fliplr(decimaldates1')];
      Ypatch=[strshocks_estimates{jj,1,ii}(1,:) fliplr(strshocks_estimates{jj,1,ii}(3,:))];
      Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
      set(Fpatch,'facealpha',0.6);
      set(Fpatch,'edgecolor','none');
      strs=plot(decimaldates1,strshocks_estimates{jj,1,ii}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
      plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
      hold off
      minband=min(strshocks_estimates{jj,1,ii}(1,:));
      maxband=max(strshocks_estimates{jj,1,ii}(3,:));
      space=maxband-minband;
      Ymin=minband-0.2*space;
      Ymax=maxband+0.2*space;
      set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin,Ymax],'FontName','Times New Roman');
         % top labels
         if count<=n
         title(endo{count,1},'FontWeight','normal');
         end
         % side labels
         if jj==1
         ylabel(Units{ii,1},'FontWeight','normal');
         end
      end
   end
end
    end
% save on Excel
% create the cell that will be saved on excel
strshockcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);
horzspace=repmat({''},3,5*n);
   % loop over units
   for ii=1:N
   % initiate the cell of results
   unitcell={};
      % loop over endogenous variables (horizontal dimension)
      for jj=1:n
      % create a header
      header=[{[Units{ii,1} ': ' endo{jj,1}]} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
      % complete the cell
      endocell=[[header;stringdates1 num2cell(strshocks_estimates{jj,:,ii}')] vertspace];
      % concatenate to the previous parts of unitcell
      unitcell=[unitcell endocell];
      end
   % concatenate to the previous parts of afcell
   strshockcell=[strshockcell;horzspace;unitcell];
   end
% trim
strshockcell=strshockcell(4:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strshockcell,'shocks','B2');
end
end




