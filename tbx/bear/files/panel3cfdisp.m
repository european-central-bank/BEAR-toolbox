function []=panel3cfdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref,nconds)








% preliminary task: gather in a cell the values to be plotted
% initiate the cell
plotdata=cell(n,1,N);
% because forecasts have to be computed for each unit, loop over units
for ii=1:N
% check first if there are conditions for this unit
   % if yes, fill the plotdata cell
   if nconds(ii,1)~=0
   % each cell entry is a matrix of actual and forecast values
   % this matrix comprises 4 rows: the first row is actual data, while the three other rows are the estimates (point estimates and confidence bands) for the forecasts
   % also, this matrix has a number of rows equal to the dimension of decimaldates2, which comprises the total period sample+forecasts
      % loop over variables
      for jj=1:n
         plotdata{jj,1,ii}=nan(4,size(decimaldates2,1));
         % record actual sample values
         plotdata{jj,1,ii}(1,1:T)=Yi(:,jj,ii)';
         % copy the last point of the actual sample for the forecast part of the matrix (required to have a clean plot)
         plotdata{jj,1,ii}(:,Fstartlocation-1)=repmat(Yi(Fstartlocation-1,jj,ii),4,1);
         % record forecast, lower bound
         plotdata{jj,1,ii}(2,Fstartlocation:Fendlocation)=cforecast_estimates{jj,1,ii}(1,:);
         % record forecast, point estimate
         plotdata{jj,1,ii}(3,Fstartlocation:Fendlocation)=cforecast_estimates{jj,1,ii}(2,:);
         % record forecast, upper bound
         plotdata{jj,1,ii}(4,Fstartlocation:Fendlocation)=cforecast_estimates{jj,1,ii}(3,:);
      end
   % if there are no conditions, don't do anything
   end
end



if pref.plot
% then plot the figure
cforecast=figure;
set(cforecast,'Color',[0.9 0.9 0.9]);
set(cforecast,'name','conditional forecasts');
% calculate the number of units on which conditional forecasts have been applied
cfunits=numel(find(nconds));
% initiate count
count=0;
% loop over units
for ii=1:N
   % check if there are conditions for this unit
   % if there are conditions
   if nconds(ii,1)~=0
      % loop over endogenous variables
      for jj=1:n
      % increment count
      count=count+1;
      % then plot
      subplot(cfunits,n,count)
      hold on
      Xpatch=[decimaldates2(Fstartlocation-1:Fendlocation,1)' fliplr((decimaldates2(Fstartlocation-1:Fendlocation,1))')];
      Ypatch=[plotdata{jj,1,ii}(2,Fstartlocation-1:Fendlocation) fliplr(plotdata{jj,1,ii}(4,Fstartlocation-1:Fendlocation))];
      Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
      set(Fpatch,'facealpha',0.6);
      set(Fpatch,'edgecolor','none');
      plot(decimaldates2,plotdata{jj,1,ii}(3,:),'Color',[0.4 0.4 1],'LineWidth',2);
      plot(decimaldates2,plotdata{jj,1,ii}(1,:),'Color',[0 0 0],'LineWidth',2);
      hold off
      set(gca,'XLim',[decimaldates2(1,1) decimaldates2(end,1)],'FontName','Times New Roman');
      set(gca,'XGrid','on');
      set(gca,'YGrid','on');
         % top labels
         if count<=n
         title(endo{count,1},'FontWeight','normal');
         end
         % side labels
         if jj==1
         ylabel(Units{ii,1},'FontWeight','normal');
         end
      end
   % if there are no conditions, don't do anything
   end
end
end



% save on Excel
% create the cell that will be saved on excel
cforecastcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates2,1)+3,1);
horzspace=repmat({''},3,6*n);
% loop over units
for ii=1:N
   % check if there are conditions for this unit
   % if there are conditions
   if nconds(ii,1)~=0
   % initiate the cell of results
   unitcell={};
      % loop over endogenous variables (horizontal dimension)
      for jj=1:n
      % create a header
      header=[{[Units{ii,1} ': ' endo{jj,1}]} {''} {''} {''} {''};{''} {''} {''} {''} {''};{''} {'actual'} {'lower bound'} {'median'} {'upper bound'}];
      % complete the cell
      endocell=[[header;stringdates2 num2cell((plotdata{jj,1,ii})')] vertspace];
      % concatenate to the previous parts of unitcell
      unitcell=[unitcell endocell];
      end
   % concatenate to the previous parts of cforecastcell
   cforecastcell=[cforecastcell;horzspace;unitcell];
   % if there are no conditions, don't do anything
   end
end
% trim
cforecastcell=cforecastcell(4:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],cforecastcell,'cond forecasts','B2');
end




