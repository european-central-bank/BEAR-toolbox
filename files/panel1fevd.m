function [fevd_estimates]=panel1fevd(N,n,irf_estimates,IRFperiods,gamma,Units,endo,pref)








% FEVD estimation

% create the output cell fevd_record
fevd_estimates={};
% preliminary tasks
% create the first cell
temp=cell(n,n+1);
% start by filling the first column of every Tij matrix in the cell
% loop over rows of temp
for jj=1:n
   % loop over columns of temp
   for kk=1:n
   % square each element
   temp{jj,kk}(1,1)=irf_estimates{jj,kk}(2,1).^2;
   end
end
% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:n
   % loop over columns of temp
   for kk=1:n
      % loop over remaining columns
      for ll=2:IRFperiods
      % define the column as the square of the corresponding column in orthogonalised_irf_record
      % additioned to the value of the preceeding columns, which creates the cumulation
      temp{jj,kk}(1,ll)=irf_estimates{jj,kk}(2,ll)^2+temp{jj,kk}(:,ll-1);
      end
   end
end
% multiply each matrix in the cell by the variance of the structural shocks
% loop over rows of temp
for jj=1:n
% loop over columns of temp
   for kk=1:n
   % multiply column kk of the matrix by the variance of the structural shock
   temp{jj,kk}(1,:)=temp{jj,kk}(1,:)*gamma(kk,kk);
   end
end
% obtain now the values for Ti, the (n+1)th matrix of each row
% loop over rows of temp
for jj=1:n
% start the summation over Tij matrices
temp{jj,n+1}=temp{jj,1};
   % sum over remaining columns
   for kk=2:n
   temp{jj,n+1}=temp{jj,n+1}+temp{jj,kk};
   end      
end
% fill the cell
% loop over rows of fevd_estimates
for jj=1:n
   % loop over columns of fevd_estimates
   for kk=1:n
   % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
   fevd_estimates{jj,kk}=temp{jj,kk}./temp{jj,n+1};
   end
end




% plot the figure
if pref.plot
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
   plot(temp,'Color',[0.4 0.4 1],'LineWidth',2);
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
horzspace=repmat({''},3,3*n);
% loop over endogenous variables
for ii=1:n
% initiate the cell of results
endocell={};
   % loop over shocks
   for jj=1:n
   % create a header
   header=[{['part of ' endo{ii,1} ' fluctuation due to ' endo{jj,1} ' shocks']} {''};{''} {''};{''} {'median'}];
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





