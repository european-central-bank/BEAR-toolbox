function [hd_estimates]=panel1hd(Y,X,N,n,m,p,T,k,D,bhat,endo,Units,decimaldates1,stringdates1,pref)










% estimate the historical decomposition

% preliminary tasks
% first create the hd_record and temp cells
hd_estimates={};
% recover Bhat
Bhat=reshape(bhat,k,n);
% obtain irfs and orthogonalised irfs
[~,ortirfmatrix]=irfsim(bhat,D,n,m,p,k,T);
% loop over units
for ii=1:N
temp={};
% obtain residuals and structural disturbances
% residuals
EPS(:,:,ii)=Y(:,:,ii)-X(:,:,ii)*Bhat;
%structural disturbances
ETA(:,:,ii)=(D\EPS(:,:,ii)')';
% step 5: compute the historical contribution of each shock
% fill the Yhd matrices
   % loop over rows of hd_estimates
   for jj=1:n
      % loop over columns of hd_estimates
      for kk=1:n
      %create the virf and vshocks vectors
         for ll=1:T
         virf(ll,1)=ortirfmatrix(jj,kk,ll);
         end
      vshocks=ETA(:,kk,ii);
         % loop over sample periods
         for ll=1:T
         hd_estimates{jj,kk,ii}(1,ll)=virf(1:ll,1)'*flipud(vshocks(1:ll,1));
         end
      end
   end
   % step 6: compute the contributions of deterministic variables
   % loop over rows of temp/hd_estimates
   for jj=1:n
   % fill the Ytot matrix in temp
   % initial condition
   temp{jj,1}=hd_estimates{jj,1,ii};
      % sum over the remaining columns of hd_estimates
      for kk=2:n
      temp{jj,1}=temp{jj,1}+hd_estimates{jj,kk,ii};
      end
   % fill the Y matrix in temp
   temp{jj,2}=Y(:,jj,ii)';
   % fill the Yd matrix in hd_record
   hd_estimates{jj,n+1,ii}=temp{jj,2}-temp{jj,1};
   % go for next variable
   end
end




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
      % loop over shocks
      for kk=1:n+1
      % increment count
      count=count+1;
      % then plot
      subplot(N*n,n+1,count)
      temp=hd_estimates{jj,kk,ii};
      hold on
      plot(decimaldates1,temp(1,:)','Color',[0.4 0.4 1],'LineWidth',2);
      plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
      hold off
      set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
         % top labels
         if (jj==1 && kk<=n)
         title([Units{ii,1} '\_' endo{kk,1}],'FontWeight','normal');
         elseif (jj==1 && kk==n+1)
         title('Exogenous','FontWeight','normal');
         end
         % side labels
         if kk==1
         ylabel([Units{ii,1} '\_' endo{jj,1}],'FontWeight','normal');
         end
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
horzspace=repmat({''},2,3*(n+1));
% loop over units
for ii=1:N
   % loop over endogenous variables
   for jj=1:n
   % initiate the cell of results
   endocell={};
      % loop over shocks
      for kk=1:n
      % create a header
      header=[{['fluctuation of ' Units{ii,1} '_' endo{jj,1} ' due to ' Units{ii,1} '_' endo{kk,1} ' shocks']} {''} ;{''} {''};{''} {'median'}];
      % complete the cell
      tempcell=[[header;stringdates1 num2cell((hd_estimates{jj,kk,ii}(1,:))')] vertspace];
      % concatenate to the previous parts of unitcell
      endocell=[endocell tempcell];
      end
   % exogenous contribution
   header=[{['fluctuation of ' Units{ii,1} '_' endo{jj,1} ' due to exogenous']} {''};{''} {''};{''} {'median'}];
   % complete the cell
   tempcell=[[header;stringdates1 num2cell((hd_estimates{jj,n+1,ii}(1,:))')] vertspace];
   % concatenate to the previous parts of unitcell
   endocell=[endocell tempcell];
   % concatenate to the previous parts of irfcell
   hdcell=[hdcell;horzspace;endocell];
   end
hdcell=[hdcell;horzspace];
end
% trim
hdcell=hdcell(3:end-2,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],hdcell,'hist decomposition','B2');
end




