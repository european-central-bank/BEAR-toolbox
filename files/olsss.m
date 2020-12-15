function []=olsss(Y,X,n,m,p,Bhat,stringdates1,decimaldates1,endo,pref)


% function []=olsss(Y,X,n,m,p,Bhat,stringdates1,decimaldates1,endo,datapath)
% calculates and displays the steady-state for the OLS VAR
% inputs:  - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8) 
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - cell 'stringdates1': date strings for the sample period
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - cell 'endo': list of endogenous variables of the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none


% this function estimates the steady-state, using (a.7.6)


% first compute the steady-state values

% recover the coefficient matrices A1,...,Ap and C, as defined in (1.1.2)
% first, calculate B and take its transpose BT
BT=Bhat';
% estimate the summation term I-A1-...-Ap in
summation=eye(n);
   for jj=1:p
   summation=summation-BT(:,(jj-1)*n+1:jj*n);
   end
% recover C
C=BT(:,end-m+1:end);
% now calculate the product of the inverse of the summation with C
product=summation\C;
% keep only the exogenous regressor part of X
X_exo=X(:,end-m+1:end)';
% compute the steady-state values
ssvalues=product*X_exo;





% create steady-state figure

sstate=figure;
set(sstate,'Color',[0.9 0.9 0.9]);
set(sstate,'name','steady-state');
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
for ii=1:n
subplot(nrows,ncolumns,ii);
hold on
ss=plot(decimaldates1,ssvalues(ii,:),'Color',[0.4 0.4 1],'LineWidth',2);
actual=plot(decimaldates1,Y(:,ii),'Color',[0 0 0],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(min(ssvalues(ii,:)),min(Y(:,ii)));
maxband=max(max(ssvalues(ii,:)),max(Y(:,ii)));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin,Ymax],'FontName','Times New Roman');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'interpreter','latex');
   if ii==1
   plotlegend=legend([ss,actual],'steady-state','actual');
   set(plotlegend,'FontName','Times New Roman');
   end
end





% finally, save in excel

% create the cell that will be saved on excel
sscell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates1,1)+3,1);
% loop over variables (horizontal dimension)
for ii=1:n
% create cell of steady-state record for variable ii
temp=['steady-state and actual: ' endo{ii,1}];
ss_i=[temp {''} {''};{''} {''} {''};{''} {'sample'} {'median'};stringdates1 num2cell(Y(:,ii)) num2cell(ssvalues(ii,:))'];
sscell=[sscell ss_i vertspace];
end
% trim
sscell=sscell(:,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],sscell,'steady state','B2');
end
