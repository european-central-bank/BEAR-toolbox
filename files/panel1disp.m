function []=panel1disp(X,Y,n,N,m,p,T,k,q,const,bhat,sigmahat,sigmahatb,Units,endo,exo,gamma_estimates,D_estimates,startdate,enddate,Fstartdate,Fcenddate,Fcperiods,Feval,Fcomp,data_endo_c,forecast_estimates,stringdates3,cband,pref,IRF,IRFt,names)









% before displaying and saving the results, start estimating the coefficients and evaluation measures for the model

% obtain the VAR coefficient estimates
% the median of the distribution is just the OLS estimate
b_median=bhat;
% obtain the standard deviation for the coefficients: by assumption, it is given by sigmahatb
b_std=diag(sigmahatb);
% build the confidence intervals, using the fact the the mean-group estimator assumes a normal distribution
for ii=1:q
b_lbound(ii,:)=norminv((1-cband)/2,b_median(ii,1),b_std(ii,1));
b_ubound(ii,:)=norminv(1-(1-cband)/2,b_median(ii,1),b_std(ii,1));
end
sigma_median=sigmahat;

% check first whether the model is stationary, using (1.9.1)
[stationary eigmodulus]=checkstable(bhat,n,p,k);
Bhat=reshape(bhat,k,n);


% the other measures are unit-specific, hence, loop over units
for ii=1:N


% obtain predicted values
Yp(:,:,ii)=X(:,:,ii)*Bhat;
% then produce the corresponding residuals, using (1.9.4)
EPS(:,:,ii)=Y(:,:,ii)-Yp(:,:,ii);


% Compute then the sum of squared residuals
% compute first the RSS matrix, defined in (1.9.5)
RSS(:,:,ii)=EPS(:,:,ii)'*EPS(:,:,ii);
% retain only the diagonal elements to get the vector of RSSi values
rss(:,:,ii)=diag(RSS(:,:,ii));


% Go on calculating R2
% generate Mbar
Mbar=eye(T)-ones(T,T)/T;
% then compute the TSS matrix, defined in (1.9.8)
TSS(:,:,ii)=Y(:,:,ii)'*Mbar*Y(:,:,ii);
% generate the R2 matrix in (1.9.9)
R2(:,:,ii)=eye(n)-RSS(:,:,ii)./TSS(:,:,ii);
% retain only the diagonal elements to get the vector of R2 values
r2(:,:,ii)=diag(R2(:,:,ii));


% then calculate the adjusted R2, using (1.9.11)
R2bar(:,:,ii)=eye(n)-((T-1)/(T-k))*(eye(n)-R2(:,:,ii));
% retain only the diagonal elements to get the vector of R2bar values
r2bar(:,:,ii)=diag(R2bar(:,:,ii));


% finally, compute the Akaike and Bayesian information criteria
% obtain first the likelihood value for the system
loglik(:,:,ii)=(-T*n/2)*(1+log(2*pi))-(T/2)*log(det(RSS(:,:,ii)/T));
% then derive the criteria in turn
aic(:,:,ii)=-2*(loglik(:,:,ii)/T)+2*(q/T);
bic(:,:,ii)=-2*(loglik(:,:,ii)/T)+q*log(T)/T;

end




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

VARtypeinfo='Panel VAR: Mean-Group Estimator (OLS)';
fprintf('%s\n',VARtypeinfo);
fprintf(fid,'%s\n',VARtypeinfo);

if IRFt==1
SVARinfo='structural decomposition: none';
fprintf('%s\n',SVARinfo);
fprintf(fid,'%s\n',SVARinfo);
elseif IRFt==2
SVARinfo='structural decomposition: choleski factorisation'; 
fprintf('%s\n',SVARinfo);
fprintf(fid,'%s\n',SVARinfo);
elseif IRFt==3
SVARinfo='structural decomposition: triangular factorisation'; 
fprintf('%s\n',SVARinfo);
fprintf(fid,'%s\n',SVARinfo);
end

temp='units: ';
for ii=1:N
temp=[temp ' ' Units{ii,1} ' '];
end
unitinfo=temp;
fprintf('%s\n',unitinfo);
fprintf(fid,'%s\n',unitinfo);

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


coeffinfo=['VAR coefficients (Common to all units):'];
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
      values=[b_median((ii-1)*k+n*(kk-1)+jj,1) b_std((ii-1)*k+n*(kk-1)+jj,1) b_lbound((ii-1)*k+n*(kk-1)+jj,1) b_ubound((ii-1)*k+n*(kk-1)+jj,1)];
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
         values=[b_median(ii*k-m+jj,1) b_std(ii*k-m+jj,1) b_lbound(ii*k-m+jj,1) b_ubound(ii*k-m+jj,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   % if there is a constant
   else
   % display the results related to the constant
         values=[b_median(ii*k-m+1,1) b_std(ii*k-m+1,1) b_lbound(ii*k-m+1,1) b_ubound(ii*k-m+1,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
      % if there is no other exogenous, stop here
      if m==1
      % if there are other exogenous, display their results
      else
         for jj=1:m-1
         values=[b_median(ii*k-m+jj+1,1) b_std(ii*k-m+jj+1,1) b_lbound(ii*k-m+jj+1,1) b_ubound(ii*k-m+jj+1,1)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   end

fprintf('%s\n','');
fprintf(fid,'%s\n','');



% display evaluation measures

   % loop over units
   for jj=1:N
   unitinfo=['unit: ' Units{jj,1}];
   fprintf('%s\n',unitinfo);
   fprintf(fid,'%s\n',unitinfo);

   rssinfo=['Sum of squared residuals: ' num2str(rss(ii,1,jj),'%.2f')];
   fprintf('%s\n',rssinfo);
   fprintf(fid,'%s\n',rssinfo);

   r2info=['R-squared: ' num2str(r2(ii,1,jj),'%.3f')];
   fprintf('%s\n',r2info);
   fprintf(fid,'%s\n',r2info);

   adjr2info=['adj. R-squared: ' num2str(r2bar(ii,1,jj),'%.3f')];
   fprintf('%s\n',adjr2info);
   fprintf(fid,'%s\n',adjr2info);

   fprintf('%s\n','');
   fprintf(fid,'%s\n','');

   end

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
   for jj=1:n
   temp=[];
      for kk=1:n
      % convert matrix entry into string
      number=num2str(sigma_median(jj,kk),'% .3f');
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

% then display the results for D and gamma, if a structural decomposition was selected

   if IRF==1 && IRFt~=1
   fprintf('%s\n','');
   fprintf(fid,'%s\n','');
   svarinfo1=['D (structural decomposition matrix): posterior estimates'];
   fprintf('%s\n',svarinfo1);
   fprintf(fid,'%s\n',svarinfo1);

   % recover D
   D=reshape(D_estimates,n,n);
   % calculate the (integer) length of the largest number in D, for formatting purpose
   width=length(sprintf('%d',floor(max(abs(vec(D))))));
   % add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
   width=width+5;
      for jj=1:n
      temp=[];
         for kk=1:n
         % convert matrix entry into string
         number=num2str(D(jj,kk),'% .3f');
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

   fprintf('%s\n','');
   fprintf(fid,'%s\n','');

   svarinfo2=['gamma (structural disturbances covariance matrix): posterior estimates'];
   fprintf('%s\n',svarinfo2);
   fprintf(fid,'%s\n',svarinfo2);

   % recover gamma
   gamma=reshape(gamma_estimates,n,n);
   % calculate the (integer) length of the largest number in gamma, for formatting purpose
   width=length(sprintf('%d',floor(max(abs(vec(gamma))))));
   % add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
   width=width+5;
      for jj=1:n
      temp=[];
         for kk=1:n
         % convert matrix entry into string
         number=num2str(gamma(jj,kk),'% .3f');
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
   end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display VAR stability results
eigmodulus=reshape(eigmodulus,p,n);
stabilityinfo1=['Roots of the characteristic polynomial (modulus):'];
fprintf('%s\n',stabilityinfo1);
fprintf(fid,'%s\n',stabilityinfo1);
for jj=1:p
temp=num2str(eigmodulus(jj,1),'%.3f');
   for kk=2:n
   temp=[temp,'  ',num2str(eigmodulus(jj,kk),'%.3f')];
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
end



fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');






% now initiate the elements that are unit specific
ferrors=[];
sferrors=[];
sumsferrors=[];
RMSE=[];
absferrors=[];
sumabsferrors=[]; 
MAE=[];
absratioferrors=[];
sumabsratioferrors=[];
MAPE=[];
sendo=[];
sumsendo=[];
leftterm=[];
sforecasts=[];
sumsforecasts=[];
rightterm=[];
Ustat=[];




% loop over units
for ii=1:N
unitinfo=['unit-specific components: ' Units{ii,1}];
fprintf('%s\n',unitinfo);
fprintf(fid,'%s\n',unitinfo);

fprintf('%s\n','');
fprintf(fid,'%s\n','');

% display the model information criteria (Akaike and Bayesian)
criterioninfo1=['Model information criteria:'];
fprintf('%s\n',criterioninfo1);
fprintf(fid,'%s\n',criterioninfo1);
criterioninfo2=['Akaike Information Criterion (AIC):   ' num2str(aic(1,1,ii),'%.3f')];
fprintf('%s\n',criterioninfo2);
fprintf(fid,'%s\n',criterioninfo2);
criterioninfo3=['Bayesian Information Criterion (BIC): ' num2str(bic(1,1,ii),'%.3f')];
fprintf('%s\n',criterioninfo3);
fprintf(fid,'%s\n',criterioninfo3);


fprintf('%s\n','');
fprintf(fid,'%s\n','');




% estimate and print forecast evaluation criteria (if activated)
% first, note that forecast evaluation can only be conducted if there is some observable data after the beginning of the forecast
if Feval==1 && Fcomp==1


   % preliminary task: obtain a matrix of forecasts over the common periods
   for jj=1:n
   forecast_c(:,jj,ii)=forecast_estimates{jj,1,ii}(2,1:Fcperiods)';
   end
   % then compute the matrix of forecast errors
   ferrors(:,:,ii)=data_endo_c(:,:,ii)-forecast_c(:,:,ii);


   % compute first the sequential RMSE, defined in (a.8.11)

   % square the forecast error matrix entrywise
   sferrors(:,:,ii)=ferrors(:,:,ii).^2;
   % sum entries sequentially
   sumsferrors(1,:,ii)=sferrors(1,:,ii);
   for jj=2:Fcperiods
   sumsferrors(jj,:,ii)=sumsferrors(jj-1,:,ii)+sferrors(jj,:,ii);
   end
   % divide by the number of forecast periods and take square roots to obtain RMSE
   for jj=1:Fcperiods
   RMSE(jj,:,ii)=((1/jj)*sumsferrors(jj,:,ii)).^0.5;
   end


   % compute then the sequential MAE, defined in (a.8.12)

   % take the absolute value of the forecast error matrix
   absferrors(:,:,ii)=abs(ferrors(:,:,ii));
   % sum entries sequentially
   sumabsferrors(1,:,ii)=absferrors(1,:,ii);
   for jj=2:Fcperiods
   sumabsferrors(jj,:,ii)=sumabsferrors(jj-1,:,ii)+absferrors(jj,:,ii);
   end
   % divide by the number of forecast periods to obtain MAE
   for jj=1:Fcperiods
   MAE(jj,:,ii)=(1/jj)*sumabsferrors(jj,:,ii);
   end


   % compute the sequential MAPE, defined in (a.8.13)

   % divide entrywise by actual values and take absolute values
   absratioferrors(:,:,ii)=abs(ferrors(:,:,ii)./data_endo_c(:,:,ii));
   % sum entries sequentially
   sumabsratioferrors(1,:,ii)=absratioferrors(1,:,ii);
   for jj=2:Fcperiods
   sumabsratioferrors(jj,:,ii)=sumabsratioferrors(jj-1,:,ii)+absratioferrors(jj,:,ii);
   end
   % divide by 100*(number of forecast periods) to obtain MAPE
   for jj=1:Fcperiods
   MAPE(jj,:,ii)=(100/jj)*sumabsratioferrors(jj,:,ii);
   end


   % compute the Theil's inequality coefficient, defined in (a.8.14)

   % first compute the left term of the denominator
   % square entrywise the matrix of actual data
   sendo(:,:,ii)=data_endo_c(:,:,ii).^2;
   % sum entries sequentially
   sumsendo(1,:,ii)=sendo(1,:,ii);
   for jj=2:Fcperiods
   sumsendo(jj,:,ii)=sumsendo(jj-1,:,ii)+sendo(jj,:,ii);
   end
   % divide by the number of forecast periods and take square roots
   for jj=1:Fcperiods
   leftterm(jj,:,ii)=((1/jj)*sumsendo(jj,:,ii)).^0.5;
   end
   % then compute the right term of the denominator
   % square entrywise the matrix of forecast values
   sforecasts(:,:,ii)=forecast_c(:,:,ii).^2;
   % sum entries sequentially
   sumsforecasts(1,:,ii)=sforecasts(1,:,ii);
   for jj=2:Fcperiods
   sumsforecasts(jj,:,ii)=sumsforecasts(jj-1,:,ii)+sforecasts(jj,:,ii);
   end
   % divide by the number of forecast periods and take square roots
   for jj=1:Fcperiods
   rightterm(jj,:,ii)=((1/jj)*sumsforecasts(jj,:,ii)).^0.5;
   end
   % finally, compute the U stats
   Ustat(:,:,ii)=RMSE(:,:,ii)./(leftterm(:,:,ii)+rightterm(:,:,ii));


% if forecast evaluation is not requested or not possible, do not do anything
end





% now, if forecast evaluation i activated, print the results and display them
if Feval==1

Fevalinfo='Forecast evaluation:';
fprintf('%s\n',Fevalinfo);
fprintf(fid,'%s\n',Fevalinfo);

fprintf('%s\n','');
fprintf(fid,'%s\n','');


% if forecast evaluation is not possible, return a message to signal it

if Fcomp==0

finfo1=['Forecast evaluation cannot be conducted.'];
fprintf('%s\n',finfo1);
fprintf(fid,'%s\n',finfo1);
finfo2=['Forecasts start in ' Fstartdate ', while observable data is available only until ' names{end,1} '.'];
fprintf('%s\n',finfo2);
fprintf(fid,'%s\n',finfo2);
finfo3=['To obtain forecast evaluation, the forecast start date must be anterior to the end of the data set.'];
fprintf('%s\n',finfo3);
fprintf(fid,'%s\n',finfo3);



% if forecast evaluation is possible, display the results
elseif Fcomp==1

finfo1=['Evaluation conducted over ' num2str(Fcperiods) ' periods (from ' Fstartdate ' to ' Fcenddate ').'];
fprintf('%s\n',finfo1);
fprintf(fid,'%s\n',finfo1);

   % loop over endogenous variables
   for kk=1:n

   fprintf('%s\n','');
   fprintf(fid,'%s\n','');

   endoinfo=['Endogenous: ' endo{kk,1}];
   fprintf('%s\n',endoinfo);
   fprintf(fid,'%s\n',endoinfo);

   temp='fprintf(''%12s';
      for jj=1:Fcperiods-1
      temp=[temp ' %10s'];
      end
   temp=[temp ' %10s\n'','''''];
      for jj=1:Fcperiods
      temp=[temp ',''' stringdates3{jj,1} ''''];
      end
   temp=[temp ');'];
   eval(temp);
   temp='fprintf(fid,''%12s';
      for jj=1:Fcperiods-1
      temp=[temp ' %10s'];
      end
   temp=[temp ' %10s\n'','''''];
      for jj=1:Fcperiods
      temp=[temp ',''' stringdates3{jj,1} ''''];
      end
   temp=[temp ');'];
   eval(temp);
   
   label='RMSE:       ';
   values=RMSE(1:Fcperiods,kk,ii)';
   temp='fprintf(''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='MAE:        ';
   values=MAE(1:Fcperiods,kk,ii)';
   temp='fprintf(''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='MAPE:       ';
   values=MAPE(1:Fcperiods,kk,ii)';
   temp='fprintf(''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='Theil''s U:  ';
   values=Ustat(1:Fcperiods,kk,ii)';
   temp='fprintf(''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   end
end

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');



end

end


fclose(fid);


