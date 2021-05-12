function []=panel1plot(endo,Units,X,Y,N,n,m,p,k,T,bhat,decimaldates1,stringdates1,pref)









% actual vs. fitted

% recover the matrix of coefficients Bhat
Bhat=reshape(bhat,k,n);
% initiate predictions
Ytilde=[];
% loop over units
for ii=1:N
% first compute fitted values for the unit
Ytilde(:,:,ii)=X(:,:,ii)*Bhat;
end
% then plot the figure
if pref.plot
actualfitted=figure;
set(actualfitted,'Color',[0.9 0.9 0.9]);
set(actualfitted,'name','actual vs fitted')
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
   plot(decimaldates1,Y(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
   plot(decimaldates1,Ytilde(:,jj,ii),'Color',[1 0 0],'LineWidth',2);
   hold off
   set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
      % top labels
      if count<=n
      title(endo{count,1},'FontWeight','normal');
      end
      % side labels
      if jj==1
      ylabel(Units{ii,1},'FontWeight','normal');
      end
      % legend
      if ii==1 && jj==1
      plotlegend=legend('actual','fitted');
      set(plotlegend,'FontName','Times New Roman');
      end
   end
end
end
% save on Excel
% create the cell that will be saved on excel
afcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);
horzspace=repmat({''},3,4*n);
% loop over units
for ii=1:N
% initiate the cell of results
unitcell={};
   % loop over endogenous variables (horizontal dimension)
   for jj=1:n
   % create a header
   header=[{[Units{ii,1} ': ' endo{jj,1}]} {''} {''};{''} {''} {''};{''} {'sample'} {'fitted'}];
   % complete the cell
   endocell=[[header;stringdates1 num2cell(Y(:,jj,ii)) num2cell(Ytilde(:,jj,ii))] vertspace];
   % concatenate to the previous parts of unitcell
   unitcell=[unitcell endocell];
   end
% concatenate to the previous parts of afcell
afcell=[afcell;horzspace;unitcell];
end
% trim
afcell=afcell(4:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],afcell,'actual fitted','B2');
end




% residuals

% inititate the matrix of residuals
EPStilde=[];
% loop over units
for ii=1:N
% estimate the residuals for this unit
EPStilde(:,:,ii)=Y(:,:,ii)-Ytilde(:,:,ii);
end
if pref.plot
% using these values, plot
residuals=figure;
set(residuals,'Color',[0.9 0.9 0.9]);
set(residuals,'name','residuals')
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
   plot(decimaldates1,EPStilde(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
   set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
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
% save on Excel
% create the cell that will be saved on excel
residcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);
horzspace=repmat({''},3,3*n);
% loop over units
for ii=1:N
% initiate the cell of results
unitcell={};
   % loop over endogenous variables (horizontal dimension)
   for jj=1:n
   % create a header
   header=[{[Units{ii,1} ': ' endo{jj,1}]} {''};{''} {''};{''} {'median'}];
   % complete the cell
   endocell=[[header;stringdates1 num2cell(EPStilde(:,jj,ii))] vertspace];
   % concatenate to the previous parts of unitcell
   unitcell=[unitcell endocell];
   end
% concatenate to the previous parts of afcell
residcell=[residcell;horzspace;unitcell];
end
% trim
residcell=residcell(4:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],residcell,'resids','B2');
end



% steady-state

% compute first the steady-state values
% recover the coefficient matrices A1,...,Ap and C, as defined in (1.1.2)
% first, calculate B and take its transpose BT
BT=reshape(bhat,k,n)';
% estimate the summation term I-A1-...-Ap in
summation=eye(n);
   for jj=1:p
   summation=summation-BT(:,(jj-1)*n+1:jj*n);
   end
% recover C
C=BT(:,end-m+1:end);
% now calculate the product of the inverse of the summation with C
product=summation\C;
ssvalues=[];
% the steady-state will be computed for each unit; hence, loop over units
for ii=1:N
% keep only the exogenous regressor part of X
X_exo=X(:,end-m+1:end,ii)';
% compute the steady-state values
ssvalues(:,:,ii)=product*X_exo;
end
if pref.plot
% then plot the figure
sstate=figure;
set(sstate,'Color',[0.9 0.9 0.9]);
set(sstate,'name','steady-state')
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
   ss=plot(decimaldates1,ssvalues(jj,:,ii),'Color',[0.4 0.4 1],'LineWidth',2);
   actual=plot(decimaldates1,Y(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
   plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
   hold off
   minband=min(min(ssvalues(jj,:,ii)),min(Y(:,jj,ii)));
   maxband=max(max(ssvalues(jj,:,ii)),max(Y(:,jj,ii)));
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
      % legend
      if ii==1 && jj==1
      plotlegend=legend([ss,actual],'steady-state','actual');
      set(plotlegend,'FontName','Times New Roman');
      end
   end
end
end
% save on Excel
% create the cell that will be saved on excel
sscell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);
horzspace=repmat({''},3,4*n);
% loop over units
for ii=1:N
% initiate the cell of results
unitcell={};
   % loop over endogenous variables (horizontal dimension)
   for jj=1:n
   % create a header
   header=[{[Units{ii,1} ': ' endo{jj,1}]} {''} {''};{''} {''} {''};{''} {'actual'} {'s.state'}];
   % complete the cell
   endocell=[[header;stringdates1 num2cell(Y(:,jj,ii)) num2cell(ssvalues(jj,:,ii)')] vertspace];
   % concatenate to the previous parts of unitcell
   unitcell=[unitcell endocell];
   end
% concatenate to the previous parts of afcell
sscell=[sscell;horzspace;unitcell];
end
% trim
sscell=sscell(4:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],sscell,'steady state','B2');
end

