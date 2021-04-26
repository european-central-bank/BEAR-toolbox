function []=panel3disp(n,N,m,p,k,T,Yi,Xi,Units,endo,exo,const,beta_gibbs,beta_median,beta_std,beta_lbound,beta_ubound,sigma_gibbs,sigma_median,D_estimates,gamma_estimates,lambda1,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names)
















% start displaying and saving the general results


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

VARtypeinfo='Panel VAR: random effect model (Zellner and Hong)';
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

hyperparam1='hyperparameters:';
fprintf('%s\n',hyperparam1);
fprintf(fid,'%s\n',hyperparam1);

hyperparam2=['overall tightness (lambda1):              ' num2str(lambda1)];
fprintf('%s\n',hyperparam2);
fprintf(fid,'%s\n',hyperparam2);

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');







% everything else is then unit-specific, hence loop over units
for hh=1:N


% first estimate the in-sample evaluation criteria
% obtain predicted values
B_median(:,:,hh)=reshape(beta_median(:,:,hh),k,n);
Yp(:,:,hh)=Xi(:,:,hh)*B_median(:,:,hh);
% then produce the corresponding residuals, using (1.9.4)
EPS(:,:,hh)=Yi(:,:,hh)-Yp(:,:,hh);


% Compute then the sum of squared residuals
% compute first the RSS matrix, defined in (1.9.5)
RSS(:,:,hh)=EPS(:,:,hh)'*EPS(:,:,hh);
% retain only the diagonal elements to get the vector of RSSi values
rss(:,:,hh)=diag(RSS(:,:,hh));


% Go on calculating R2
% generate Mbar
Mbar=eye(T)-ones(T,T)/T;
% then compute the TSS matrix, defined in (1.9.8)
TSS(:,:,hh)=Yi(:,:,hh)'*Mbar*Yi(:,:,hh);
% generate the R2 matrix in (1.9.9)
R2(:,:,hh)=eye(n)-RSS(:,:,hh)./TSS(:,:,hh);
% retain only the diagonal elements to get the vector of R2 values
r2(:,:,hh)=diag(R2(:,:,hh));


% then calculate the adjusted R2, using (1.9.11)
R2bar(:,:,hh)=eye(n)-((T-1)/(T-k))*(eye(n)-R2(:,:,hh));
% retain only the diagonal elements to get the vector of R2bar values
r2bar(:,:,hh)=diag(R2bar(:,:,hh));


% now start the display phase: start with the name of the unit

unitinfo=['Unit: ' Units{hh,1}];
fprintf('%s\n',unitinfo);
fprintf(fid,'%s\n',unitinfo);


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display coefficient estimates
coeffinfo=['VAR coefficients:'];
fprintf('%s\n',coeffinfo);
fprintf(fid,'%s\n',coeffinfo);


% loop over the equations(that is, endogenous variables) of the model
for ii=1:n
fprintf('%s\n','');
fprintf(fid,'%s\n','');

endoinfo=['Endogenous: ' endo{ii,1}];
fprintf('%s\n',endoinfo);
fprintf(fid,'%s\n',endoinfo);

coeffheader=fprintf('%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');
coeffheader=fprintf(fid,'%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');

% handle the endogenous
   for jj=1:n
      for kk=1:p
      values=[beta_median((ii-1)*k+n*(kk-1)+jj,1,hh) beta_std((ii-1)*k+n*(kk-1)+jj,1,hh) beta_lbound((ii-1)*k+n*(kk-1)+jj,1,hh) beta_ubound((ii-1)*k+n*(kk-1)+jj,1,hh)];
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
         values=[beta_median(ii*k-m+jj,1,hh) beta_std(ii*k-m+jj,1,hh) beta_lbound(ii*k-m+jj,1,hh) beta_ubound(ii*k-m+jj,1,hh)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   % if there is a constant
   else
   % display the results related to the constant
         values=[beta_median(ii*k-m+1,1,hh) beta_std(ii*k-m+1,1,hh) beta_lbound(ii*k-m+1,1,hh) beta_ubound(ii*k-m+1,1,hh)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
      % if there is no other exogenous, stop here
      if m==1
      % if there are other exogenous, display their results
      else
         for jj=1:m-1
         values=[beta_median(ii*k-m+jj+1,1,hh) beta_std(ii*k-m+jj+1,1,hh) beta_lbound(ii*k-m+jj+1,1,hh) beta_ubound(ii*k-m+jj+1,1,hh)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   end

fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display evaluation measures

rssinfo=['Sum of squared residuals: ' num2str(rss(ii,1,hh),'%.2f')];
fprintf('%s\n',rssinfo);
fprintf(fid,'%s\n',rssinfo);

r2info=['R-squared: ' num2str(r2(ii,1,hh),'%.3f')];
fprintf('%s\n',r2info);
fprintf(fid,'%s\n',r2info);

adjr2info=['adj. R-squared: ' num2str(r2bar(ii,1,hh),'%.3f')];
fprintf('%s\n',adjr2info);
fprintf(fid,'%s\n',adjr2info);

end


fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display VAR stability results

% check whether the model is stationary
[stationary eigmodulus]=checkstable(beta_median(:,:,hh),n,p,k);
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
fprintf('%s\n',stabilityinfo2);
fprintf(fid,'%s\n',stabilityinfo2);
stabilityinfo3=['The estimated VAR model will not be stable'];
fprintf('%s\n',stabilityinfo3);
fprintf(fid,'%s\n',stabilityinfo3);
end

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

fprintf('%s\n','');
fprintf(fid,'%s\n','');


% then display the results for D and gamma, if a structural decomposition was selected

if IRF==1 && IRFt~=1
svarinfo1=['D (structural decomposition matrix): posterior estimates'];
fprintf('%s\n',svarinfo1);
fprintf(fid,'%s\n',svarinfo1);

% recover D
D=reshape(D_estimates(:,:,hh),n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(D))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(D(ii,jj),'% .3f');
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
gamma=reshape(gamma_estimates(:,:,hh),n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(gamma))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(gamma(ii,jj),'% .3f');
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


% finally, estimate and print the forecast evaluation criteria
% first note that forecast evaluation can only be conducted if it is activated, and if there is some observable data after the beginning of the forecast
if Feval==1 && Fcomp==1

% compute forecast evaluation
[RMSE MAE MAPE Ustat CRPS_estimates S1_estimates S2_estimates]=panelfeval(n,p,k,beta_gibbs(:,:,hh),sigma_gibbs(:,:,hh),forecast_record(:,:,hh),forecast_estimates(:,:,hh),Fcperiods,data_endo_c(:,:,hh),data_endo_c_lags(:,:,hh),data_exo_c,const,It,Bu);
% then display and save the results
panelfprint(n,endo,RMSE,MAE,MAPE,Ustat,CRPS_estimates,S1_estimates,S2_estimates,stringdates3,Fstartdate,Fcenddate,Fcperiods,fid);


% if forecast evaluation is activated but not possible, return a message to signal it
elseif Feval==1 && Fcomp==0

finfo1=['Forecast evaluation cannot be conducted.'];
fprintf('%s\n',finfo1);
fprintf(fid,'%s\n',finfo1);
finfo2=['Forecasts start in ' Fstartdate ', while observable data is available only until ' names{end,1} '.'];
fprintf('%s\n',finfo2);
fprintf(fid,'%s\n',finfo2);
finfo3=['To obtain forecast evaluation, the forecast start date must be anterior to the end of the data set.'];
fprintf('%s\n',finfo3);
fprintf(fid,'%s\n',finfo3);

% if forecast evaluation is not activated altogether, do not do anything
end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


end



fclose(fid);


