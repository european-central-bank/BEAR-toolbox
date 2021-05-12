function []=panel6plot(endo,Units,Xmat,Xtilde,Ymat,N,n,m,p,k,T,d,theta_median,theta_gibbs,Xi,Zeta_gibbs,It,Bu,decimaldates1,stringdates1,pref,cband,d1,d2,d3,d4,d5)











% actual vs. fitted

% obtain a point estimate Thetatilde of the structural factors, which is the median
Thetatilde=reshape(theta_median,T*d,1);
% first compute fitted values
Ytilde=Xtilde*Thetatilde;
% reshape for convenience
Ytilde=reshape(reshape(Ytilde,N*n,T)',T,n,N);
Ymat=reshape(Ymat,T,n,N);
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
   plot(decimaldates1,Ymat(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
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
   endocell=[[header;stringdates1 num2cell(Ymat(:,jj,ii)) num2cell(Ytilde(:,jj,ii))] vertspace];
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
EPStilde(:,:,ii)=Ymat(:,:,ii)-Ytilde(:,:,ii);
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

% run the Gibbs sampler for the steady-state 
[ss_record,ss_estimates]=ssgibbspan6(n,N,m,p,k,T,Xmat,theta_gibbs,Xi,It,Bu,cband);
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
   actual=plot(decimaldates1,Ymat(:,jj,ii),'Color',[0 0 0],'LineWidth',2);
   plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
   hold off
   minband=min(min(ss_estimates{jj,1}(1,:)),min(Ymat(:,jj,ii)));
   maxband=max(max(ss_estimates{jj,1}(3,:)),max(Ymat(:,jj,ii)));
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
   endocell=[[header;stringdates1 num2cell(Ymat(:,jj,ii)) num2cell(ss_estimates{jj,1}(1,:)') num2cell(ss_estimates{jj,1}(2,:)') num2cell(ss_estimates{jj,1}(3,:)')] vertspace];
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



% time-varying elements

% generate the cell of record for the time-varying elements
rec=cell(d+1,1);

% record first the factors: loop over them
for ii=1:d
   % loop over time periods
   for jj=1:T
   rec{ii}(1,jj)=quantile(theta_gibbs(ii,:,jj),(1-cband)/2);
   rec{ii}(2,jj)=quantile(theta_gibbs(ii,:,jj),0.5);
   rec{ii}(3,jj)=quantile(theta_gibbs(ii,:,jj),1-(1-cband)/2);
   end
end

% then record residual heteroskedasticity
% loop over time periods
for ii=1:T
rec{d+1,1}(1,ii)=quantile(Zeta_gibbs(ii,:),(1-cband)/2);
rec{d+1,1}(2,ii)=quantile(Zeta_gibbs(ii,:),0.5);
rec{d+1,1}(3,ii)=quantile(Zeta_gibbs(ii,:),1-(1-cband)/2);
end





if pref.plot
% plot the figure
% first calculate the number of columns and rows to create a square plot
ncolumns=ceil((d+1)^0.5);
nrows=ceil((d+1)/ncolumns);
% initiate count
count=0;

volatility=figure;
set(volatility,'Color',[0.9 0.9 0.9]);
set(volatility,'name','time-varying coefficients');


% graphs for factor 1
count=count+1;
subplot(nrows,ncolumns,count);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[rec{count}(1,:) fliplr(rec{count}(3,:))];
HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(HDpatch,'facealpha',0.5);
set(HDpatch,'edgecolor','none');
plot(decimaldates1,rec{1,1}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(rec{count}(1,:));
maxband=max(rec{count}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin Ymax],'FontName','Times New Roman');
title('common factor: \theta_{11}','FontWeight','normal');


% graphs for factor 2
% loop over factors
for ii=1:d2
% increment count
count=count+1;
% plot
subplot(nrows,ncolumns,count);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[rec{count}(1,:) fliplr(rec{count}(3,:))];
HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(HDpatch,'facealpha',0.5);
set(HDpatch,'edgecolor','none');
plot(decimaldates1,rec{count}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(rec{count}(1,:));
maxband=max(rec{count}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin Ymax],'FontName','Times New Roman');
titlestring=['title(''unit factors:\theta_{2' num2str(ii) '}'',''FontWeight'',''normal'');'];
eval(titlestring);
end


% graphs for factor 3
% loop over factors
for ii=1:d3
% increment count
count=count+1;
% plot
subplot(nrows,ncolumns,count);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[rec{count}(1,:) fliplr(rec{count}(3,:))];
HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(HDpatch,'facealpha',0.5);
set(HDpatch,'edgecolor','none');
plot(decimaldates1,rec{count}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(rec{count}(1,:));
maxband=max(rec{count}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin Ymax],'FontName','Times New Roman');
titlestring=['title(''variable factors:\theta_{3' num2str(ii) '}'',''FontWeight'',''normal'');'];
eval(titlestring);
end


% graphs for factor 4 (if applicable)
if d4~=0
   % loop over factors
   for ii=1:d4
   count=count+1;
   subplot(nrows,ncolumns,count);
   hold on
   Xpatch=[decimaldates1' fliplr(decimaldates1')];
   Ypatch=[rec{count}(1,:) fliplr(rec{count}(3,:))];
   HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(HDpatch,'facealpha',0.5);
   set(HDpatch,'edgecolor','none');
   plot(decimaldates1,rec{count}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
   plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
   hold off
   minband=min(rec{count}(1,:));
   maxband=max(rec{count}(3,:));
   space=maxband-minband;
   Ymin=minband-0.2*space;
   Ymax=maxband+0.2*space;
   set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin Ymax],'FontName','Times New Roman');
   titlestring=['title(''lag factors:\theta_{4' num2str(ii) '}'',''FontWeight'',''normal'');'];
   eval(titlestring);
   end
end


% graphs for factor 5 (if applicable)
if d5~=0
   % loop over factors
   for ii=1:d5
   count=count+1;
   subplot(nrows,ncolumns,count);
   hold on
   Xpatch=[decimaldates1' fliplr(decimaldates1')];
   Ypatch=[rec{count}(1,:) fliplr(rec{count}(3,:))];
   HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
   set(HDpatch,'facealpha',0.5);
   set(HDpatch,'edgecolor','none');
   plot(decimaldates1,rec{count}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
   plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
   hold off
   minband=min(rec{count}(1,:));
   maxband=max(rec{count}(3,:));
   space=maxband-minband;
   Ymin=minband-0.2*space;
   Ymax=maxband+0.2*space;
   set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin Ymax],'FontName','Times New Roman');
   titlestring=['title(''exogenous factors:\theta_{5' num2str(ii) '}'',''FontWeight'',''normal'');'];
   eval(titlestring);
   end
end


% graph for residual heteroskedasticity
count=count+1;
subplot(nrows,ncolumns,count);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[rec{count}(1,:) fliplr(rec{count}(3,:))];
HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(HDpatch,'facealpha',0.5);
set(HDpatch,'edgecolor','none');
plot(decimaldates1,rec{count}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(rec{count}(1,:));
maxband=max(rec{count}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin Ymax],'FontName','Times New Roman');
title('residual heteroskadasticity: \zeta','FontWeight','normal');
end






% save on Excel
% create the cell that will be saved on excel
tvcell={};
% preliminary elements
% obtain the factor that has the largest number of elements
dmax=max([d2 d3 d4 d5]);
% build space between the tables
vertspace=repmat({''},T+3,1);
horzspace=repmat({''},3,dmax*5);

% initiate count
count=0;


% common factor: theta1: 
% increment count
count=count+1;
% create a header
header=[{'common factor: theta11'} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
% complete the cell
factorcell=[[header;stringdates1 num2cell(rec{count}')] vertspace];
% if d1 is smaller than dmax, complete with empty entries
if d1<dmax
factorcell=[factorcell repmat({''},T+3,(dmax-d1)*5)];
end
% concatenate to the previous parts of unitcell
tvcell=[tvcell factorcell];


% unit factor: theta2
factorcell={};
% loop over factors
for ii=1:d2
% increment count
count=count+1;
% create a header
header=[{['unit factor: theta2' num2str(ii)]} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
% complete the cell
tempcell=[[header;stringdates1 num2cell(rec{count}')] vertspace];
factorcell=[factorcell tempcell];
end
% if d2 is smaller than dmax, complete with empty entries
if d2<dmax
factorcell=[factorcell repmat({''},T+3,(dmax-d2)*5)];
end
% concatenate to the previous parts of unitcell
tvcell=[tvcell;horzspace;factorcell];


% variable factor: theta3
factorcell={};
% loop over factors
for ii=1:d3
% increment count
count=count+1;
% create a header
header=[{['variable factor: theta3' num2str(ii)]} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
% complete the cell
tempcell=[[header;stringdates1 num2cell(rec{count}')] vertspace];
factorcell=[factorcell tempcell];
end
% if d3 is smaller than dmax, complete with empty entries
if d3<dmax
factorcell=[factorcell repmat({''},T+3,(dmax-d3)*5)];
end
% concatenate to the previous parts of unitcell
tvcell=[tvcell;horzspace;factorcell];


% factor 4 (if applicable)
if d4~=0
factorcell={};
   % loop over factors
   for ii=1:d4
   % increment count
   count=count+1;
   % create a header
   header=[{['lag factor: theta4' num2str(ii)]} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
   % complete the cell
   tempcell=[[header;stringdates1 num2cell(rec{count}')] vertspace];
   factorcell=[factorcell tempcell];
   end
   % if d4 is smaller than dmax, complete with empty entries
   if d4<dmax
   factorcell=[factorcell repmat({''},T+3,(dmax-d4)*5)];
   end
   % concatenate to the previous parts of unitcell
   tvcell=[tvcell;horzspace;factorcell];
end


% factor 5 (if applicable)
if d5~=0
factorcell={};
   % loop over factors
   for ii=1:d5
   % increment count
   count=count+1;
   % create a header
   header=[{['exogenous factor: theta5' num2str(ii)]} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
   % complete the cell
   tempcell=[[header;stringdates1 num2cell(rec{count}')] vertspace];
   factorcell=[factorcell tempcell];
   end
   % if d5 is smaller than dmax, complete with empty entries
   if d5<dmax
   factorcell=[factorcell repmat({''},T+3,(dmax-d5)*5)];
   end
   % concatenate to the previous parts of unitcell
   tvcell=[tvcell;horzspace;factorcell];
end


% residual heteroskedasticity
factorcell={};
% increment count
count=count+1;
% create a header
header=[{'residual heteroskedasticity: zeta'} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
% complete the cell
factorcell=[[header;stringdates1 num2cell(rec{count}')] vertspace];
% if dmax is larger than 1, complete with empty entries
if dmax>1
factorcell=[factorcell repmat({''},T+3,(dmax-1)*5)];
end
% concatenate to the previous parts of unitcell
tvcell=[tvcell;horzspace;factorcell];


% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],tvcell,'time variation','B2');
end

