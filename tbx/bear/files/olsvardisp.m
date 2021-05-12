function []=olsvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,X,Y,n,m,p,k,q,T,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref,favar,strctident)



% function []=olsvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,X,Y,n,m,p,k,T,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,datapath)
% displays estimation results for the OLS VAR model on Matlab prompt, creates a copy of these results on the text file results.txt
% inputs:  - vector 'beta_median': median value of the posterior distribution of beta
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - cell 'endo': list of endogenous variables of the model
%          - cell 'exo': list of exogenous variables of the model
%          - string 'startdate': start date of the sample
%          - string 'enddate': end date of the sample
%          - cell 'stringdates1': date strings for the sample period
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none 



% before displaying and saving the results, start estimating the evaluation measures for the model


% obtain first a point estimate betatilde of the VAR coefficients
% this is simply beta_mean, which is both the mean and the median of the normal distribution
betatilde=beta_median;
Btilde=reshape(betatilde,k,n);
% use this estimate to produce predicted values for the model, following (1.9.3)
Ytilde=X*Btilde;
% then produce the corresponding residuals, using (1.9.4)
EPStilde=Y-Ytilde;


% check first whether the model is stationary, using (1.9.1)
[stationary,eigmodulus]=checkstable(betatilde,n,p,k);


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
R2bar=eye(n)-((T-1)/(T-k))*(eye(n)-R2);
% retain only the diagonal elements to get the vector of R2bar values
r2bar=diag(R2bar);


% finally, compute the Akaike and Bayesian information criteria
% obtain first the likelihood value for the system
loglik=(-T*n/2)*(1+log(2*pi))-(T/2)*log(det(RSS/T));
% then derive the criteria in turn
aic=-2*(loglik/T)+2*(q/T);
bic=-2*(loglik/T)+q*log(T)/T;


% now start displaying and saving the results


% preliminary task: create and open the txt file used to save the results

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'wt');

% print toolbox header

fprintf('%s\n','');
fprintf(fid,'%s\n','');

% print the list of contributors
printcontributors;

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

if favar.FAVAR==1
    VARtypeinfo='Standard OLS VAR, factor augmented (FAVAR)';
    fprintf('%s\n',VARtypeinfo);
    fprintf(fid,'%s\n',VARtypeinfo);
    if favar.blocks==1
        for ii=1:favar.nbnames
            fprintf('%s%s%s%s%s%d%s%s%s%s%s%d%s%s%.2f%%\n','Block',' ',favar.bnames{ii,1},' ','(',size(favar.X_block{ii,1},2),' ','information variables)',' ','-- number of factors (PCs):',' ',favar.bnumpc{ii,1},' ','-- variance explained by all factors: ',favar.bsumvariaexpl{ii,1});
            fprintf(fid,'%s%s%s%s%s%d%s%s%s%s%s%d%s%s%.2f%%\n','Block',' ',favar.bnames{ii,1},' ','(',size(favar.X_block{ii,1},2),' ','information variables)',' ','-- number of factors (PCs):',' ',favar.bnumpc{ii,1},' ','-- variance explained by all factors: ',favar.bsumvariaexpl{ii,1});
        end
    else
    fprintf('%s%s%d%s%s%.2f%%\n','number of factors (PCs):',' ',favar.numpc,' ','-- variance explained by all factors: ',favar.sumvariaexpl);
    fprintf(fid,'%s%s%d%s%s%.2f%%\n','number of factors (PCs):',' ',favar.numpc,' ','-- variance explained by all factors: ',favar.sumvariaexpl);
    end
else
    VARtypeinfo='Standard OLS VAR';
    fprintf('%s\n',VARtypeinfo);
    fprintf(fid,'%s\n',VARtypeinfo);
end

if IRFt==1
SVARinfo='structural decomposition: none (IRFt=1)'; 
elseif IRFt==2
SVARinfo='structural decomposition: Cholesky factorisation (IRFt=2)'; 
elseif IRFt==3
SVARinfo='structural decomposition: triangular factorisation (IRFt=3)'; 
elseif IRFt==4
SVARinfo=['structural decomposition: ',strctident.hbartext_signres,strctident.hbartext_favar_signres,strctident.hbartext_zerores,strctident.hbartext_favar_zerores,strctident.hbartext_magnres,strctident.hbartext_favar_magnres,strctident.hbartext_relmagnres,strctident.hbartext_favar_relmagnres,strctident.hbartext_FEVDres,strctident.hbartext_favar_FEVDres,strctident.hbartext_CorrelInstrumentShock,':::',' restrictions (IRFt=4)'];
SVARinfo=erase(SVARinfo,', :::'); % delete the last ,
elseif IRFt==5
SVARinfo=['structural decomposition: IV (',strctident.Instrument,') (IRFt=5)']; 
elseif IRFt==6
SVARinfo_temp=[strctident.hbartext_signres,strctident.hbartext_favar_signres,strctident.hbartext_zerores,strctident.hbartext_favar_zerores,strctident.hbartext_magnres,strctident.hbartext_favar_magnres,strctident.hbartext_relmagnres,strctident.hbartext_favar_relmagnres,strctident.hbartext_FEVDres,strctident.hbartext_favar_FEVDres,strctident.hbartext_CorrelInstrumentShock,':::',' restrictions'];
SVARinfo_temp=erase(SVARinfo_temp,', :::'); % delete the last ,
SVARinfo=['structural decomposition: IV (' ,strctident.Instrument,') & ',SVARinfo_temp, ' (IRFt=6)'];
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

temp='exogenous variables: ';
if const==0 && m==0
temp=[temp ' none'];
elseif const==1 && m==1
temp=[temp ' constant '];
elseif const==0 && m>0
   for ii=1:m-1
   temp=[temp ' ' exo{ii,1} ' '];
   end
elseif const==1 && m>1
temp=[temp ' constant '];
   for ii=1:m-1
   temp=[temp ' ' exo{ii,1} ' '];
   end
end
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

fprintf('%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');
fprintf(fid,'%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');

% handle the endogenous
   for jj=1:n
      for kk=1:p
      values=[beta_median((ii-1)*k+n*(kk-1)+jj,1) beta_std((ii-1)*k+n*(kk-1)+jj,1) beta_lbound((ii-1)*k+n*(kk-1)+jj,1) beta_ubound((ii-1)*k+n*(kk-1)+jj,1)];
      fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1},'(-',int2str(kk),')'),values);
      fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1},'(-',int2str(kk),')'),values);
      end
   end

% handle the exogenous
   % if there is no constant:
   if const==0
      % if there is no exogenous at all, obvioulsy, don't display anything
      if m==0
      % if there is no constant but some other exogenous, display them
      else
         for jj=1:m
         values=[beta_median(ii*k-m+jj,1) beta_std(ii*k-m+jj,1) beta_lbound(ii*k-m+jj,1) beta_ubound(ii*k-m+jj,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   % if there is a constant
   else
   % display the results related to the constant
         values=[beta_median(ii*k-m+1,1) beta_std(ii*k-m+1,1) beta_lbound(ii*k-m+1,1) beta_ubound(ii*k-m+1,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
      % if there is no other exogenous, stop here
      if m==1
      % if there are other exogenous, display their results
      else
         for jj=1:m-1
         values=[beta_median(ii*k-m+jj+1,1) beta_std(ii*k-m+jj+1,1) beta_lbound(ii*k-m+jj+1,1) beta_ubound(ii*k-m+jj+1,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
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





% display the model information criteria (Akaike and Bayesian)
criterioninfo1=['Model information criteria:'];
fprintf('%s\n',criterioninfo1);
fprintf(fid,'%s\n',criterioninfo1);
criterioninfo2=['Akaike Information Criterion (AIC):   ' num2str(aic,'%.3f')];
fprintf('%s\n',criterioninfo2);
fprintf(fid,'%s\n',criterioninfo2);
criterioninfo3=['Bayesian Information Criterion (BIC): ' num2str(bic,'%.3f')];
fprintf('%s\n',criterioninfo3);
fprintf(fid,'%s\n',criterioninfo3);


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
if stationary==1
stabilityinfo2=['No root lies outside the unit circle.'];
stabilityinfo3=['The estimated VAR model satisfies the stability condition'];
fprintf('%s\n',stabilityinfo2);
fprintf(fid,'%s\n',stabilityinfo2);
fprintf('%s\n',stabilityinfo3);
fprintf(fid,'%s\n',stabilityinfo3);
else
stabilityinfo2=['No root lies outside the unit circle.'];
stabilityinfo3=['The estimated VAR model satisfies the stability condition'];
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


% then plot actual vs. fitted
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
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal','interpreter','latex');
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
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal','interpreter','latex');
end



% finally, save the results on excel
excelrecord2
