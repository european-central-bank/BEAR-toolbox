function []=TVEmavardisp(beta_median,beta_std,beta_lbound,beta_ubound,theta_median,psi_std,psi_lbound,psi_ubound,sigma_median,X,Z,Y,n,m,p,k1,k3,q1,q2,T,ar,lambda1,lambda2,lambda3,lambda4,lambda5,IRFt,beta_gibbs,endo,exo,psi_gibbs,startdate,enddate,stringdates1,decimaldates1,datapath,data_endo,TVEH,indH,pref)



% function []=mavardisp(beta_median,beta_std,beta_lbound,beta_ubound,psi_median,psi_std,psi_lbound,psi_ubound,sigma_median,X,Z,Y,n,m,p,k1,k3,q1,q2,T,ar,lambda1,lambda2,lambda3,lambda4,lambda5,IRFt,beta_gibbs,endo,exo,psi_gibbs,startdate,enddate,stringdates1,decimaldates1,datapath)
% displays estimation results for the MABVAR model on Matlab prompt, creates a copy of these results on the text file results.txt
% inputs:  - vector 'beta_median': median value of the posterior distribution of beta
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'psi_median': median value of the posterior distribution of psi
%          - vector 'psi_std': standard deviation of the posterior distribution of psi
%          - vector 'psi_lbound': lower bound of the credibility interval of psi
%          - vector 'psi_ubound': upper bound of the credibility interval of psi
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 3.5.10)
%          - matrix 'Z': matrix of exogenous regressors for the MABVAR model (defined in 3.5.10)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 3.5.10)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k1': number of endogenous coefficients to estimate for each equation in the MABVAR model (defined p 77 of technical guide)
%          - integer 'k3': number of exogenous coefficients to estimate for each equation in the reformulated MABVAR model (defined p 77 of technical guide)
%          - integer 'q1': total number of endogenous coefficients to estimate in the MABVAR model (defined p 77 of technical guide)
%          - integer 'q2': total number of exogenous coefficients to estimate in the MABVAR model (defined p 77 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - scalar 'lambda1': overall tightness hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda2': cross-variable weighting hyperparameter(defined p 16 of technical guide)
%          - scalar 'lambda3': lag decay hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda4': exogenous variable tightness hyperparameter (defined p 17 of technical guide)
%          - scalar 'lambda5': block exogeneity shrinkage hyperparameter (defined p 32 of technical guide)
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - cell 'endo': list of endogenous variables of the model
%          - matrix 'psi_gibbs': record of the gibbs sampler draws for the psi vector
%          - cell 'exo': list of exogenous variables of the model
%          - string 'startdate': start date of the sample
%          - string 'enddate': end date of the sample
%          - cell 'stringdates1': date strings for the sample period
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none



% before displaying and saving the results, start estimating the evaluation measures for the model


% obtain first a point estimate betatilde of the VAR coefficients related to endogenous variables
% this is simply beta_median, which is both the mean and the median of the normal distribution
betatilde=beta_median;
Btilde=reshape(betatilde,k1,n);
% generate U, using Btilde, from (3.5.15)
% U=eye(n*m);
%    for jj=1:p
%    U=[U;kron(eye(m),Btilde((jj-1)*n+1:jj*n,:)')];
%    end

% obtain then a point estimate psitilde of the VAR coefficients related to exogenous variables
% this is simply psi_median, which is both the mean and the median of the normal distribution
theta=theta_median;

% % combine the two to obtain vec(DELTA'), using (3.5.14)
% vecdeltap=U*psitilde;
% % recover delta
% deltap=reshape(vecdeltap,n,k3);
% DELTA=deltap';

for it=1:T+p
    eq(it,:)=(squeeze(TVEH(:,:,indH(it),it))*theta)'; % compute the equilibrium values given theta
end

temp2=data_endo-eq;
temp3=lagx(temp2,p);
Yhat=temp3(:,1:n);
Xhat=temp3(:,n+1:end);

% then produce the corresponding residuals, using (3.5.9)
EPStilde=Yhat-Xhat*Btilde;
Ytilde=Y-EPStilde;

% check first whether the model is stationary, using (1.9.1)
[stationary eigmodulus]=macheckstable(Btilde,n,p);

% Compute then the sum of squared residuals
% compute first the RSS matrix, defined in (1.9.5)
RSS=EPStilde'*EPStilde;
% retain only the diagonal elements to get the vector of RSSi values
rss=diag(RSS);

% Go on calculating R2
% generate Mbar
Mbar=eye(T)-ones(T,T)/T;
% then compute the TSS matrix, defined in (1.9.8)
TSS=Y'*Mbar*Y;
% generate the R2 matrix in (1.9.9)
R2=eye(n)-RSS./TSS;
% retain only the diagonal elements to get the vector of R2 values
r2=diag(R2);

% then calculate the adjusted R2, using (1.9.11)
R2bar=eye(n)-((T-1)/(T-(k1+m)))*(eye(n)-R2);
% retain only the diagonal elements to get the vector of R2bar values
r2bar=diag(R2bar);







% now start displaying and saving the results


% preliminary task: create and open the txt file used to save the results

% filelocation=datapath;
% filelocation=[filelocation '\results.txt'];
% fid=fopen(filelocation,'wt');

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'wt');

% print toolbox header

fprintf('%s\n','');
fprintf(fid,'%s\n','');

fprintf('%s\n','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
fprintf('%s\n','%                                                                                                       %%');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX                                         %');
fprintf(fid,'%s\n','%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX                                     %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%    This statistical package has been developed by the external developments division of the ECB.       %');
fprintf(fid,'%s\n','%    This statistical package has been developed by the external developments division of the ECB.   %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%    Authors:                                                                                            %');
fprintf(fid,'%s\n','%    Authors:                                                                                        %');
fprintf('%s\n','%    Romain Legrand  (Romain Legrand <b00148883@essec.edu>)                                              %');
fprintf(fid,'%s\n','%    Romain Legrand  (Romain Legrand <b00148883@essec.edu>)                                          %');
fprintf('%s\n','%    Alistair Dieppe (adieppe@worldbank.org)                                                             %');
fprintf(fid,'%s\n','%    Alistair Dieppe (adieppe@worldbank.org)                                                         %');
fprintf('%s\n','%    Björn van Roye  (Bjorn.van_Roye@ecb.europa.eu)                                                      %');
fprintf(fid,'%s\n','%    Björn van Roye  (Bjorn.van_Roye@ecb.europa.eu)                                                  %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%    Version 4.4                                                                                         %');
fprintf(fid,'%s\n','%    Version 4.4                                                                                     %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%    The authors are grateful to Paolo Bonomolo, Marta Banbura, Martin Bruns, Fabio Canova,              %');
fprintf(fid,'%s\n','%    The authors are grateful to Paolo Bonomolo, Marta Banbura, Martin Bruns, Fabio Canova,          %');
fprintf('%s\n','%    Matteo Ciccarelli, Marek Jarocinski, Niccolo Battistini, Gabriel Bobeica                            %');
fprintf(fid,'%s\n','%    Matteo Ciccarelli, Marek Jarocinski, Niccolo Battistini, Gabriel Bobeica                        %');
fprintf('%s\n','%    Michele Lenza, Chiara Osbat, Mirela Miescu, Gary Koop, Giorgio Primiceri                            %');
fprintf(fid,'%s\n','%    Michele Lenza, Chiara Osbat, Mirela Miescu, Gary Koop, Giorgio Primiceri,                       %');
fprintf('%s\n','%    Michal Rubaszek, Barbara Rossi, Ben Schumann, Peter Welz, Hugo Vega de la Cruz and Francesca Loria. %');
fprintf(fid,'%s\n','%  Michal Rubaszek, Barbara Rossi, Ben Schumann, Peter Welz, Hugo Vega de la Cruz and Francesca Loria%');
fprintf('%s\n','%    valuable input and advice which contributed to improve the quality of this work.                    %');
fprintf(fid,'%s\n','%  valuable input and advice which contributed to improve the quality of this work.                  %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%   These programmes are the responsibilities of the authors and not of the ECB and the Worldbank.       %'); 
fprintf(fid,'%s\n','%   These programmes are the responsibilities of the authors and not of the ECB and the Worldbank.   %'); 
fprintf('%s\n','%   Errors and ommissions remain those of the authors.                                                   %'); 
fprintf(fid,'%s\n','%   Errors and ommissions remain those of the authors.                                               %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');
fprintf('%s\n','%    Please do not use or quote this work without permission.                                            %');
fprintf(fid,'%s\n','%    Please do not use or quote this work without permission.                                        %');
fprintf('%s\n','%                                                                                                        %');
fprintf(fid,'%s\n','%                                                                                                    %');    
fprintf('%s\n','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

% print then estimation results

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

toolboxinfo='BEAR toolbox estimates';
fprintf('%s\n',toolboxinfo);
fprintf(fid,'%s\n',toolboxinfo);

time=clock;
datestring=datestr(time);
dateinfo=['Date: ' datestring(1,1:11) '   Time: ' datestring(1,13:17)];
fprintf('%s\n',dateinfo);
fprintf(fid,'%s\n',dateinfo);

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

VARtypeinfo='Mean-adjusted BVAR';
fprintf('%s\n',VARtypeinfo);
fprintf(fid,'%s\n',VARtypeinfo);

if IRFt==1
SVARinfo='structural decomposition: none'; 
elseif IRFt==2
SVARinfo='structural decomposition: choleski factorisation'; 
elseif IRFt==3
SVARinfo='structural decomposition: triangular factorisation'; 
elseif IRFt==4
SVARinfo='structural decomposition: sign restrictions'; 
end
fprintf('%s\n',SVARinfo);
fprintf(fid,'%s\n',SVARinfo);

temp='endogenous variables: ';
for ii=1:n
temp=[temp ' ' endo{ii,1} ' '];
end
endoinfo=temp;
fprintf('%s\n',endoinfo);
fprintf(fid,'%s\n',endoinfo);

temp='exogenous variables: constant';
% if m>1
%    for ii=1:m-1
%    temp=[temp ' ' exo{ii,1} ' '];
%    end
% end
exoinfo=temp;
fprintf('%s\n',exoinfo);
fprintf(fid,'%s\n',exoinfo);

sampledateinfo=['estimation sample: ' startdate '-' enddate];
fprintf('%s\n',sampledateinfo);
fprintf(fid,'%s\n',sampledateinfo);

samplelengthinfo=['sample size (omitting initial conditions): ' num2str(T)];
fprintf('%s\n',samplelengthinfo);
fprintf(fid,'%s\n',samplelengthinfo);

laginfo=['number of lags included in regression: ' num2str(p)];
fprintf('%s\n',laginfo);
fprintf(fid,'%s\n',laginfo);

hyperparam1='hyperparameters:';
fprintf('%s\n',hyperparam1);
fprintf(fid,'%s\n',hyperparam1);


%hyperparam2=['autoregressive coefficient (ar):          ' num2str(ar)];
%fprintf('%s\n',hyperparam2);
%fprintf(fid,'%s\n',hyperparam2);


hyperparam3=['overall tightness (lambda1):              ' num2str(lambda1)];
fprintf('%s\n',hyperparam3);
fprintf(fid,'%s\n',hyperparam3);


hyperparam4=['cross-variable weighting (lambda2):       ' num2str(lambda2)];
fprintf('%s\n',hyperparam4);
fprintf(fid,'%s\n',hyperparam4);


hyperparam5=['lag decay (lambda3):                      ' num2str(lambda3)];
fprintf('%s\n',hyperparam5);
fprintf(fid,'%s\n',hyperparam5);


%hyperparam6=['exogenous variable tightness (lambda4):   ' num2str(lambda4)];
%fprintf('%s\n',hyperparam6);
%fprintf(fid,'%s\n',hyperparam6);


hyperparam7=['block exogeneity shrinkage (lambda5):     ' num2str(lambda5)];
fprintf('%s\n',hyperparam7);
fprintf(fid,'%s\n',hyperparam7);



% display coefficient estimates


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


coeffinfo=['VAR coefficients (beta): posterior estimates'];
fprintf('%s\n',coeffinfo);
fprintf(fid,'%s\n',coeffinfo);


for ii=1:n

fprintf('%s\n','');
fprintf(fid,'%s\n','');
if ii~=1
fprintf('%s\n','');
fprintf(fid,'%s\n','');
end

endoinfo=['Endogenous: ' endo{ii,1}];
fprintf('%s\n',endoinfo);
fprintf(fid,'%s\n',endoinfo);

coeffheader=fprintf('%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');
coeffheader=fprintf(fid,'%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');

% handle the endogenous
   for jj=1:n
      for kk=1:p
      values=[beta_median((ii-1)*k1+n*(kk-1)+jj,1) beta_std((ii-1)*k1+n*(kk-1)+jj,1) beta_lbound((ii-1)*k1+n*(kk-1)+jj,1) beta_ubound((ii-1)*k1+n*(kk-1)+jj,1)];
      fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1},'(-',int2str(kk),')'),values);
      fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1},'(-',int2str(kk),')'),values);
      end
   end

% handle the exogenous
% display the results related to the constant
values=[theta_median(ii,1) psi_std(ii,1) psi_lbound(ii,1) psi_ubound(ii,1)];
fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
   % if there is no other exogenous, stop here
   if m==1
   % if there are other exogenous, display their results
   elseif m>1
      for jj=1:m-1
      %values=[theta_median(n*jj+ii,1) psi_std(n*jj+ii,1)
      %psi_lbound(n*jj+ii,1) psi_ubound(n*jj+ii,1)]; BVR, commeted out as
      %it was unused!
      %fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
     %fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
     end
   end

fprintf('%s\n','');
fprintf(fid,'%s\n','');

% display evaluation measures
rssinfo=['Sum of squared residuals: ' num2str(rss(ii,1),'%.2f')];
fprintf('%s\n',rssinfo);
fprintf(fid,'%s\n',rssinfo);

r2info=['R-squared: ' num2str(r2(ii,1),'%.3f')];
fprintf('%s\n',r2info);
fprintf(fid,'%s\n',r2info);

adjr2info=['adj. R-squared: ' num2str(r2bar(ii,1),'%.3f')];
fprintf('%s\n',adjr2info);
fprintf(fid,'%s\n',adjr2info);

end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display VAR stability results
eigmodulus=reshape(eigmodulus,p,n);
stabilityinfo1=['Roots of the characteristic polynomial (modulus):'];
fprintf('%s\n',stabilityinfo1);
fprintf(fid,'%s\n',stabilityinfo1);
for ii=1:p
temp=num2str(eigmodulus(ii,1),'%.3f');
   for jj=2:n
   temp=[temp,'  ',num2str(eigmodulus(ii,jj),'%.3f')];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end
if stationary==1;
stabilityinfo2=['No root lies outside the unit circle.'];
stabilityinfo3=['The estimated VAR model satisfies the stability condition'];
fprintf('%s\n',stabilityinfo2);
fprintf(fid,'%s\n',stabilityinfo2);
fprintf('%s\n',stabilityinfo3);
fprintf(fid,'%s\n',stabilityinfo3);
else
stabilityinfo2=['Warning: at leat one root lies on or outside the unit circle.'];
stabilityinfo3=['The estimated VAR model will not be stable'];
fprintf('%s\n',stabilityinfo2);
fprintf(fid,'%s\n',stabilityinfo2);
fprintf('%s\n',stabilityinfo3);
fprintf(fid,'%s\n',stabilityinfo3);
end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display posterior for sigma
sigmainfo=['sigma (residual covariance matrix): posterior estimates'];
fprintf('%s\n',sigmainfo);
fprintf(fid,'%s\n',sigmainfo);
% calculate the (integer) length of the largest number in sigma, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(sigma_median))))));
% add a separator, a potential minus sign, and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(sigma_median(ii,jj),'% .3f');
      % pad potential missing blanks
      while numel(number)<width
      number=[' ' number];
      end
   number=[number '  '];
   temp=[temp number];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end


fclose(fid);



% Finally, display the results in terms of graph
if pref.plot

% graph the empirical posterior distribution of the VAR parameters
% first reshape the gibbs sampler output to be compatible with the way Matlab uses subplot
% first concatenate psi_gibbs on beta_gibbs to obtain a vector similar to beta in the classical BVAR model
temp=[];
for ii=1:n
temp=[temp;beta_gibbs((ii-1)*k1+1:ii*k1,:)];
   for jj=1:m
   temp=[temp;psi_gibbs((jj-1)*m+ii,:)];
   end
end
beta_reshape=temp;
[beta_swap]=betaswap(beta_reshape,n,m,p,k1+m);
plotvar=1;
plotlag=1;
plotexo=1;
plotconst=1;
% then plot the figure
%{
postdis=figure;
set(postdis,'Color',[0.9 0.9 0.9]);
set(postdis,'name','posterior ditribution of VAR coefficients');
for ii=1:(q1+q2)
subplot(n,k1+m,ii)
hist(beta_swap(ii,:),20);
histproperties=findobj(gca,'Type','patch');
set(histproperties,'FaceColor',[0.7 0.78 1],'EdgeColor',[0 0 0],'LineWidth',0.1);
set(gca,'FontName','Times New Roman');
   % top labels for endogenous
   if ii<=n*p
   temp=[endo{plotvar,1} '(-' num2str(plotlag) ')'];
   title(temp,'FontWeight','normal');
      if plotlag<p
      plotlag=plotlag+1;
      elseif plotlag==p
      plotlag=1;
      plotvar=plotvar+1;
      end
   end
   % top labels for exogenous     
   %if ii==k1+1
   %title('Constant','FontWeight','normal');
   %end
   %if ii>k1+1 && ii<=k1+m
   %title(exo{plotexo,1},'FontWeight','normal');
   %plotexo=plotexo+1;
   %end
   % side labels
   %if rem((ii-1)/(k1+m),1)==0
   ylabel(endo{(ii-1)/(k1+m)+1,1},'FontWeight','normal');
   %end
end
%}

% plot actual vs. fitted
actualfitted=figure;
set(actualfitted,'Color',[0.9 0.9 0.9]);
set(actualfitted,'name','model estimation: actual vs fitted')
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
for ii=1:n
subplot(nrows,ncolumns,ii)
hold on
plot(decimaldates1,Y(:,ii),'Color',[0 0 0],'LineWidth',2);
plot(decimaldates1,Ytilde(:,ii),'Color',[1 0 0],'LineWidth',2);
hold off
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10);
   if ii==1
   plotlegend=legend('actual','fitted');
   set(plotlegend,'FontName','Times New Roman');
   end
end


% plot the residuals
residuals=figure;
set(residuals,'Color',[0.9 0.9 0.9]);
set(residuals,'name','model estimation: residuals')
for ii=1:n
subplot(nrows,ncolumns,ii)
plot(decimaldates1,EPStilde(:,ii),'Color',[0 0 0],'LineWidth',2)
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10);
end


end

% finally, save the results on excel
excelrecord2



