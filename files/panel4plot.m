function []=panel4plot(endo,Units,Xi,Yi,N,n,m,p,k,T,beta_median,beta_gibbs,It,Bu,decimaldates1,stringdates1,pref,cband,favar)









% actual vs. fitted

% initiate predictions
Ytilde=[];
% loop over units
for ii=1:N
% obtain a point estimate betatilde of the VAR coefficients
% use the point estimate, which is simply the median
betatilde=beta_median(:,:,ii);
Btilde=reshape(betatilde,k,n);
% compute fitted values for the unit
Ytilde(:,:,ii)=Xi(:,:,ii)*Btilde;
end
if pref.plot
% then plot the figure
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
   plot(decimaldates1,Yi(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
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
   endocell=[[header;stringdates1 num2cell(Yi(:,jj,ii)) num2cell(Ytilde(:,jj,ii))] vertspace];
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
EPStilde(:,:,ii)=Yi(:,:,ii)-Ytilde(:,:,ii);
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

% initiate the cell storing the steady-state draws
ss_record={};
ss_estimates={};
% % ss_estimates_constant={};
% % ss_estimates_exogneous={};
% run the Gibbs sampler for the steady-state (common to all units)
ss_record=ssgibbs(n,m,p,k,Xi(:,:,1),beta_gibbs,It,Bu,favar);
% % % run the Gibbs sampler for the steady-state constant part (common to all units)
% % ss_record_constant=ssgibbs(n,m,p,k,Xi(:,:,1),beta_gibbs,It,Bu,favar);
% % % run the Gibbs sampler for the steady-state constant part (common to all units)
% % ss_record_exogenous=ssgibbs(n,m,p,k,Xi(:,:,1),beta_gibbs,It,Bu,favar);
% obtain point estimates and credibility interval
ss_estimates=ssestimates(ss_record,n,T,cband);
% % ss_estimates=ssestimates(ss_record,ss_record_constant,ss_record_exogenous,n,m,T,cband);
% % ss_estimates_constant=ssestimates(ss_record,ss_record_constant,ss_record_exogenous,n,m,T,cband);
% % ss_estimates_exogenous=ssestimates(ss_record,ss_record_constant,ss_record_exogenous,n,m,T,cband);

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
   Xpatch=[decimaldates1' fliplr(decimaldates1')];
   Ypatch=[ss_estimates{jj,1}(1,:) fliplr(ss_estimates{jj,1}(3,:))];
   Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(Fpatch,'facealpha',0.6);
   set(Fpatch,'edgecolor','none');
   ss=plot(decimaldates1,ss_estimates{jj,1}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
   actual=plot(decimaldates1,Yi(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
   plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
   hold off
   minband=min(min(ss_estimates{jj,1}(1,:)),min(Yi(:,jj,ii)));
   maxband=max(max(ss_estimates{jj,1}(3,:)),max(Yi(:,jj,ii)));
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
horzspace=repmat({''},3,6*n);
% loop over units
for ii=1:N
% initiate the cell of results
unitcell={};
   % loop over endogenous variables (horizontal dimension)
   for jj=1:n
   % create a header
   header=[{[Units{ii,1} ': ' endo{jj,1}]} {''} {''} {''} {''};{''} {''} {''} {''} {''};{''} {'actual'} {'lower bound'} {'median'} {'upper bound'}];
   % complete the cell
   endocell=[[header;stringdates1 num2cell(Yi(:,jj,ii)) num2cell(ss_estimates{jj,1}(1,:)') num2cell(ss_estimates{jj,1}(2,:)') num2cell(ss_estimates{jj,1}(3,:)')] vertspace];
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



