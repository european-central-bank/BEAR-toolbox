function [hd_estimates]=olshdecomp(betahat,Bhat,sigmahat,Y,X,n,m,p,T,k,IRFt,endo,stringdates1,decimaldates1,D,pref)


% function [hd_estimates]=olshdecomp(betahat,Bhat,sigmahat,Y,X,n,m,p,T,k,IRFt,endo,stringdates1,decimaldates1,datapath)
% computes and displays historical decomposition values for the OLS VAR model
% inputs:  - vector 'betahat': OLS VAR coefficients in vectorised form (defined in 1.1.15) 
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - matrix 'sigmahat': OLS VAR variance-covariance matrix of residuals (defined in 1.1.10)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - cell 'endo': list of endogenous variables of the model
%          - cell 'stringdates1': date strings for the sample period
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: - cell 'hd_estimates': lower bound, point estimates, and upper bound for the historical decomposition


% this function implements the procedure p58-59 of the technical guide


% preliminary tasks
% first create the hd_record and temp cells
hd_estimates=cell(n,n+1);
temp=cell(n,2);


% recover D
if IRFt==1
D=eye(n);
gamma=sigmahat;
elseif IRFt==2
D=chol(nspd(sigmahat),'lower');
gamma=eye(n);
elseif IRFt==3
[D,gamma]=triangf(sigmahat);
elseif IRFt==5 || IRFt==6
    D = D;
else
end


% obtain irfs and orthogonalised irfs
[~,ortirfmatrix]=irfsim(betahat,D,n,m,p,k,T);


% step 4: obtain residuals and structural disturbances
% residuals
EPS=Y-X*Bhat;
%structural disturbances
ETA=(D\EPS')';


% step 5: compute the historical contribution of each shock
% fill the Yhd matrices
% loop over rows of hd_estimates
for ii=1:n
   % loop over columns of hd_estimates
   for jj=1:n
   %create the virf and vshocks vectors
      for kk=1:T
      virf(kk,1)=ortirfmatrix(ii,jj,kk);
      end
   vshocks=ETA(:,jj);
      % loop over sample periods
      for kk=1:T
      hd_estimates{ii,jj}(1,kk)=virf(1:kk,1)'*flipud(vshocks(1:kk,1));
      end
   end
end




% step 6: compute the contributions of deterministic variables
% loop over rows of temp/hd_estimates
for ii=1:n
% fill the Ytot matrix in temp
% initial condition
temp{ii,1}=hd_estimates{ii,1};
   % sum over the remaining columns of hd_estimates
   for jj=2:n
   temp{ii,1}=temp{ii,1}+hd_estimates{ii,jj};
   end
% fill the Y matrix in temp
temp{ii,2}=Y(:,ii)';
% fill the Yd matrix in hd_record
hd_estimates{ii,n+1}=temp{ii,2}-temp{ii,1};
% go for next variable
end



% plot the results
% transpose the cell of records (required for the plot function in order to obtain correctly ordered plots)
hd_estimates=hd_estimates';
% create figure for historical decomposition
if IRFt ==2  || IRFt ==3 || IRFt ==4
hd=figure;
set(hd,'Color',[0.9 0.9 0.9]);
set(hd,'name','historical decomposition');
for ii=1:n*(n+1)
subplot(n,n+1,ii);
hold on
plot(decimaldates1,hd_estimates{ii}(1,:)','Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
% top labels
   if ii<=n
   title(endo{ii,1},'FontWeight','normal');
   end
   if ii==n+1
   title('Exogenous','FontWeight','normal');
   end
% side labels
   if rem((ii-1)/(n+1),1)==0
   ylabel(endo{(ii-1)/(n+1)+1,1},'FontWeight','normal');
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

% finally, record results in excel

% retranspose the cell of records
hd_estimates=hd_estimates';
% create the cell that will be saved on excel
hdcell={};
% build preliminary elements: space between the tables
horzspace=repmat({''},2,3*(n+1));
vertspace=repmat({''},T+3,1);
% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:n
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
   temp=['contribution of ' endo{jj,1} ' shocks in ' endo{ii,1} ' fluctuation'];
   hd_ij=[temp {''} ;{''} {''};{''} {'median'};stringdates1 num2cell((hd_estimates{ii,jj})')];
   tempcell=[tempcell hd_ij vertspace];
   end
% consider the contribution of exogenous
temp=['contribution of exogenous in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {'median'};stringdates1 num2cell((hd_estimates{ii,n+1})')];
tempcell=[tempcell hd_ij vertspace];
hdcell=[hdcell;horzspace;tempcell];
end
% trim
hdcell=hdcell(3:end,1:end-1);
% write in excel
if pref.results==1
    xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],hdcell,'hist decomposition','B2');
end 
end
