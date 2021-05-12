function []=bvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,log10ml,dic,X,Y,n,m,p,k,q,T,prior,bex,hogs,lrp,H,ar,lambda1,lambda2,lambda3,lambda4,lambda5,lambda6,lambda7,lambda8,IRFt,const,beta_gibbs,endo,data_endo,exo,startdate,enddate,decimaldates1,stringdates1,pref,scoeff,iobs,PriorExcel,strctident,favar,theta_median,TVEH,indH)




% function []=bvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,log10ml,X,Y,n,m,p,k,q,T,prior,bex,ar,lambda1,lambda2,lambda3,lambda4,lambda5,IRFt,const,beta_gibbs,endo,exo,startdate,enddate,stringdates1,decimaldates1,datapath)
% displays estimation results for the BVAR model on Matlab prompt, creates a copy of these results on the text file results.txt
% and records the information contained in the worksheets 'actual fitted' and 'resids' of the excel spreadsheet 'results.xls'
% inputs:  - vector 'beta_median': median value of the posterior distribution of beta
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)
%          - scalar 'log10ml': base 10 log of the marginal likelihood (defined in 1.2.9)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'prior': value to determine which prior applies to the model
%          - integer 'bex': 0-1 value to determine if block exogeneity is applied to the model
%          - integer 'hogs': 0-1 value to determine if hyperparameter optimisation by gid search is applied
%          - scalar 'ar': prior value of the autoregressive coefficient on own first lag (defined p 15 of technical guide)
%          - scalar 'lambda1': overall tightness hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda2': cross-variable weighting hyperparameter(defined p 16 of technical guide)
%          - scalar 'lambda3': lag decay hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda4': exogenous variable tightness hyperparameter (defined p 17 of technical guide)
%          - scalar 'lambda5': block exogeneity shrinkage hyperparameter (defined p 32 of technical guide)
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
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
% this is simply the median
betatilde=beta_median;
Btilde=reshape(betatilde,k,n);

% use this estimate to produce predicted values for the model, following (a.8.2)
Ytilde=X*Btilde;
% then produce the corresponding residuals, using (a.8.3)
EPStilde=Y-Ytilde;

if prior==61 % different calculation for mean-adjusted prior
for it=1:T+p
    eq(it,:)=(squeeze(TVEH(:,:,indH(it),it))*theta_median)'; % compute the equilibrium values given theta
end
temp2=data_endo-eq;
temp3=lagx(temp2,p);
Yhat=temp3(:,1:n);
Xhat=temp3(:,n+1:end);
% then produce the corresponding residuals, using (3.5.9)
Ytilde=Y-EPStilde;
EPStilde=Yhat-Xhat*Btilde;
end

% check first whether the model is stationary, using (a.7.2)
[stationary,eigmodulus]=checkstable(betatilde,n,p,k);


% Compute then the sum of squared residuals
% compute first the RSS matrix, defined in (a.8.4)
RSS=EPStilde'*EPStilde;
% retain only the diagonal elements to get the vector of RSSi values
rss=diag(RSS);


% Go on calculating R2
% generate Mbar
Mbar=eye(T)-ones(T,T)/T;
% then compute the TSS matrix, defined in (a.8.7)
TSS=Y'*Mbar*Y;
% generate the R2 matrix in (a.8.8)
R2=eye(n)-RSS./TSS;
% retain only the diagonal elements to get the vector of R2 values
r2=diag(R2);


% then calculate the adjusted R2, using (a.8.9)
R2bar=eye(n)-((T-1)/(T-k))*(eye(n)-R2);
% retain only the diagonal elements to get the vector of R2bar values
r2bar=diag(R2bar);



% now start displaying and saving the results

% preliminary task: create and open the txt file used to save the results

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'wt');

% print toolbox header
% fprint(fid) is to print into the txt file
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
    VARtypeinfo='Bayesian VAR, factor augmented (FAVAR)';
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
VARtypeinfo='Bayesian VAR';
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
if prior~=61 %%%%% it was commented in the TVEmavardisp file
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
end

sampledateinfo=['estimation sample: ' startdate '-' enddate];
fprintf('%s\n',sampledateinfo);
fprintf(fid,'%s\n',sampledateinfo);

samplelengthinfo=['sample size (omitting initial conditions): ' num2str(T)];
fprintf('%s\n',samplelengthinfo);
fprintf(fid,'%s\n',samplelengthinfo);

laginfo=['number of lags included in regression: ' num2str(p)];
fprintf('%s\n',laginfo);
fprintf(fid,'%s\n',laginfo);

if prior==11
priorinfo='prior: Minnesota (sigma as univariate AR)';
elseif prior==12
priorinfo='prior: Minnesota (sigma as diagonal VAR estimates)';
elseif prior==13
priorinfo='prior: Minnesota (sigma as full VAR estimates)';
elseif prior==21
priorinfo='prior: normal-Wishart (sigma as univariate AR)';
elseif prior==22
priorinfo='prior: normal-Wishart (sigma as identity)';
elseif prior==31
priorinfo='prior: independent normal-Wishart (sigma as univariate AR)';
elseif prior==32
priorinfo='prior: independent normal-Wishart (sigma as identity)';
elseif prior==41
priorinfo='prior: normal-diffuse';
elseif prior==51
priorinfo='prior: dummy observations';
elseif prior==61
priorinfo='prior: mean-adjusted';
end
fprintf('%s\n',priorinfo);
fprintf(fid,'%s\n',priorinfo);


if hogs==1
hyperparam1='hyperparameters (values optimised by grid search):';  
else
hyperparam1='hyperparameters:';
end
fprintf('%s\n',hyperparam1);
fprintf(fid,'%s\n',hyperparam1);

if PriorExcel==1
    arprint=[];
    for ii=1:n
        arprint=[arprint num2str(ar(ii,1)) '  '];
    end
 hyperparam2=['autoregressive coefficients (ar):                ' arprint];
else
 hyperparam2=['autoregressive coefficients (ar):                ' num2str(ar(1,1))];
end
fprintf('%s\n',hyperparam2);
fprintf(fid,'%s\n',hyperparam2);


hyperparam3=['overall tightness (lambda1):                    ' num2str(lambda1)];
fprintf('%s\n',hyperparam3);
fprintf(fid,'%s\n',hyperparam3);


if prior==11||prior==12||prior==13||prior==31||prior==32||prior==41||prior==61
hyperparam4=['cross-variable weighting (lambda2):             ' num2str(lambda2)];
fprintf('%s\n',hyperparam4);
fprintf(fid,'%s\n',hyperparam4);
end


hyperparam5=['lag decay (lambda3):                            ' num2str(lambda3)];
fprintf('%s\n',hyperparam5);
fprintf(fid,'%s\n',hyperparam5);


%if PriorExcel==0
%hyperparam6=['exogenous variable tightness (lambda4):         ' num2str(lambda4)];
%else
%hyperparam6=['exogenous variable tightness (lambda4): provided by user'];
%end
%fprintf('%s\n',hyperparam6);
%fprintf(fid,'%s\n',hyperparam6);


%hyperparam6=['exogenous variable tightness (lambda4):         ' num2str(lambda4)];
%fprintf('%s\n',hyperparam6);
%fprintf(fid,'%s\n',hyperparam6);


if bex==1
hyperparam7=['block exogeneity shrinkage (lambda5):           ' num2str(lambda5)];
fprintf('%s\n',hyperparam7);
fprintf(fid,'%s\n',hyperparam7);
end


if scoeff==1
hyperparam8=['sum-of-coefficients tightness (lambda6):        ' num2str(lambda6)];
fprintf('%s\n',hyperparam8);
fprintf(fid,'%s\n',hyperparam8);
end

if iobs==1
hyperparam9=['dummy initial observation tightness (lambda7):  ' num2str(lambda7)];
fprintf('%s\n',hyperparam9);
fprintf(fid,'%s\n',hyperparam9);
end

if lrp==1
hyperparam10=['dummy initial observation tightness (lambda8):  ' num2str(lambda8)];
fprintf('%s\n',hyperparam10);
fprintf(fid,'%s\n',hyperparam10);
end


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
%          if prior~=61
         values=[beta_median(ii*k-m+1,1) beta_std(ii*k-m+1,1) beta_lbound(ii*k-m+1,1) beta_ubound(ii*k-m+1,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
%          elseif prior==61
%             values=[theta_median(ii,1) psi_std(ii,1) psi_lbound(ii,1)
%             psi_ubound(ii,1)]; %psi not used anymore
%             fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
%             fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
%          end
      % if there is no other exogenous, stop here
      if m==1
      % if there are other exogenous, display their results
      else
          if prior~=61
         for jj=1:m-1
         values=[beta_median(ii*k-m+jj+1,1) beta_std(ii*k-m+jj+1,1) beta_lbound(ii*k-m+jj+1,1) beta_ubound(ii*k-m+jj+1,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
%         elseif prior==61
      %values=[theta_median(n*jj+ii,1) psi_std(n*jj+ii,1)
      %psi_lbound(n*jj+ii,1) psi_ubound(n*jj+ii,1)]; BVR, commeted out as
      %it was unused!
      %fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
     %fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
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


% display marginal likelihood
if prior==11||prior==12||prior==13||prior==21||prior==22||(prior==31&&scoeff==0&&iobs==0)||(prior==32&&scoeff==0&&iobs==0)
log10mlinfo=['Log 10 marginal likelihood: ' num2str(log10ml,'%.2f')];
fprintf('%s\n',log10mlinfo);
fprintf(fid,'%s\n',log10mlinfo);
elseif (prior==31&&(scoeff==1||iobs==1))||(prior==32&&(scoeff==1||iobs==1))
log10mlinfo=['Log 10 marginal likelihood: not estimated (numerically instable for this prior when dummy extensions are applied)'];
fprintf('%s\n',log10mlinfo);
fprintf(fid,'%s\n',log10mlinfo);
else
log10mlinfo=['Log 10 marginal likelihood: not applicable (improper prior)'];  
fprintf('%s\n',log10mlinfo);
fprintf(fid,'%s\n',log10mlinfo);   
end

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

% display DIC test results
dicinfo=['DIC test result: ' num2str(dic,'%.2f')];
fprintf('%s\n',dicinfo);
fprintf(fid,'%s\n',dicinfo);

fprintf('%s\n','The model with smaller DIC value is preferred');
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

% display posterior for sigma
fprintf('%s\n', '')
if lrp==1
Hinfo=['H matrix (long run priors): '];
fprintf('%s\n',Hinfo);
fprintf(fid,'%s\n',Hinfo);

fmt=[repmat('%6.2f ',1,size(H,1)) '\n'];
fprintf(fmt,H);
fprintf(fid,fmt,H);
end

fclose(fid);


% Finally, display the results in terms of graph
if pref.plot

% if the chosen prior implied computation of posterior by Gibbs sampler (mixed or normal diffuse), display a plot of the empirical posterior distribution of the VAR coefficients
if prior==31||prior==32||prior==41
% graph the posterior distribution of the VAR parameters
% first reshape the gibbs sampler output to be compatible with the way Matlab uses subplot
[beta_swap]=betaswap(beta_gibbs,n,m,p,k);
plotvar=1;
plotlag=1;
plotexo=1;
plotconst=const;
% then plot the figure
postdis=figure;
set(postdis,'Color',[0.9 0.9 0.9]);
set(postdis,'name','posterior distribution of VAR coefficients');
   for ii=1:q
   subplot(n,k,ii)
   hist(beta_swap(ii,:),20);
   histproperties=findobj(gca,'Type','patch');
   set(histproperties,'FaceColor',[0.7 0.78 1],'EdgeColor',[0 0 0],'LineWidth',0.1);
   set(gca,'FontName','Times New Roman');
      % top labels for endogenous
      if ii<=n*p
      temp=[endo{plotvar,1} '(-' num2str(plotlag) ')'];
      title(temp,'FontWeight','normal','interpreter','latex');
         if plotlag<p
         plotlag=plotlag+1;
         elseif plotlag==p
         plotlag=1;
         plotvar=plotvar+1;
         end
      end
      % top labels for exogenous     
      if ii>n*p && ii<=k
         if plotconst==1
         title('Constant','FontWeight','normal','interpreter','latex');
         plotconst=0;
         else
         title(exo{plotexo,1},'FontWeight','normal','interpreter','latex');
         plotexo=plotexo+1;
         end
      end
      % side labels
      if rem((ii-1)/k,1)==0
      ylabel(endo{(ii-1)/k+1,1},'FontWeight','normal','interpreter','latex');
      end
   end
end


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

end

% finally, save the results on excel
excelrecord2

