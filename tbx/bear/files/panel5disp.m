function []=panel5disp(n,N,m,p,k,T,d1,d2,d3,d4,d5,Ymat,Xdot,Units,endo,exo,const,Xi,theta_gibbs,theta_median,theta_std,theta_lbound,theta_ubound,sigma_gibbs,sigma_median,D_estimates,gamma_estimates,alpha0,delta0,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names)






% recover a point estimate (the median) of the VAR coefficients
betatilde=Xi*theta_median;
Btilde=reshape(betatilde,k,N*n);

% check whether the model is stationary
[stationary,eigmodulus]=checkstable(betatilde,N*n,p,k);

% estimate the in-sample evaluation criteria

% obtain a point estimate thetatilde of the structural factors, which is the median
thetatilde=theta_median;
% compute fitted values
Ytilde=full(Xdot*kron(speye(T),thetatilde))';
% reshape for convenience
Ytilde=reshape(Ytilde,T,n,N);
Ymat=reshape(Ymat,T,n,N);

% loop over units
for ii=1:N
% estimate the residuals for this unit
EPS(:,:,ii)=Ymat(:,:,ii)-Ytilde(:,:,ii);

% Compute then the sum of squared residuals
% compute first the RSS matrix, defined in (1.9.5)
RSS(:,:,ii)=EPS(:,:,ii)'*EPS(:,:,ii);
% retain only the diagonal elements to get the vector of RSSi values
rss(:,:,ii)=diag(RSS(:,:,ii));

% Go on calculating R2
% generate Mbar
Mbar=eye(T)-ones(T,T)/T;
% then compute the TSS matrix, defined in (1.9.8)
TSS(:,:,ii)=Ymat(:,:,ii)'*Mbar*Ymat(:,:,ii);
% generate the R2 matrix in (1.9.9)
R2(:,:,ii)=eye(n)-RSS(:,:,ii)./TSS(:,:,ii);
% retain only the diagonal elements to get the vector of R2 values
r2(:,:,ii)=diag(R2(:,:,ii));

% then calculate the adjusted R2, using (1.9.11)
R2bar(:,:,ii)=eye(n)-((T-1)/(T-k))*(eye(n)-R2(:,:,ii));
% retain only the diagonal elements to get the vector of R2bar values
r2bar(:,:,ii)=diag(R2bar(:,:,ii));

end




% estimate the forecast evaluation criteria
% first note that forecast evaluation can only be conducted if it is activated, and if there is some observable data after the beginning of the forecast
if Feval==1 && Fcomp==1

% generate the elements required for the evaluation
beta_gibbs=Xi*theta_gibbs;
forecast_record=reshape(forecast_record,N*n,1);
forecast_estimates=reshape(forecast_estimates,N*n,1);
data_endo_c=reshape(data_endo_c,Fcperiods,N*n);
data_endo_c_lags=reshape(data_endo_c_lags,p,N*n);

% compute forecast evaluation
[RMSE,MAE,MAPE,Ustat,CRPS_estimates,S1_estimates,S2_estimates]=panelfeval(N*n,p,k,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,Fcperiods,data_endo_c,data_endo_c_lags,data_exo_c,const,It,Bu);

end




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

VARtypeinfo='Panel VAR: structural factor (static)';
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

hyperparam2=['IG shape on residual variance (alpha0):       ' num2str(alpha0)];
fprintf('%s\n',hyperparam2);
fprintf(fid,'%s\n',hyperparam2);

hyperparam3=['IG scale on residual variance (delta0):       ' num2str(delta0)];
fprintf('%s\n',hyperparam3);
fprintf(fid,'%s\n',hyperparam3);

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display factor estimates

factorinfo=['Structural factors:'];
fprintf('%s\n',factorinfo);
fprintf(fid,'%s\n',factorinfo);

fprintf('%s\n','');
fprintf(fid,'%s\n','');

factorheader=fprintf('%35s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');
factorheader=fprintf(fid,'%35s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');


% common component

fprintf('%s\n','theta1 (common component)');
fprintf(fid,'%s\n','theta1 (common component)');
values=[theta_median(1,1) theta_std(1,1) theta_lbound(1,1) theta_ubound(1,1)];
fprintf('%-35s %15.3f %15.3f %15.3f %15.3f\n','common component',values);
fprintf(fid,'%-35s %15.3f %15.3f %15.3f %15.3f\n','common component',values);
fprintf('%s\n','');
fprintf(fid,'%s\n','');

% unit component

fprintf('%s\n','theta2 (unit-specific component)');
fprintf(fid,'%s\n','theta2 (unit component)');
for ii=1:d2
values=[theta_median(d1+ii,1) theta_std(d1+ii,1) theta_lbound(d1+ii,1) theta_ubound(d1+ii,1)];
fprintf('%-35s %15.3f %15.3f %15.3f %15.3f\n',['unit ' int2str(ii) ' component'],values);
fprintf(fid,'%-35s %15.3f %15.3f %15.3f %15.3f\n',['unit ' int2str(ii) ' component'],values);
end
fprintf('%s\n','');
fprintf(fid,'%s\n','');

% variable component

fprintf('%s\n','theta3 (variable-specific component)');
fprintf(fid,'%s\n','theta3 (endogenous variable component)');
for ii=1:d3
values=[theta_median(d1+d2+ii,1) theta_std(d1+d2+ii,1) theta_lbound(d1+d2+ii,1) theta_ubound(d1+d2+ii,1)];
fprintf('%-35s %15.3f %15.3f %15.3f %15.3f\n',['variable ' int2str(ii) ' component'],values);
fprintf(fid,'%-35s %15.3f %15.3f %15.3f %15.3f\n',['variable ' int2str(ii) ' component'],values);
end
fprintf('%s\n','');
fprintf(fid,'%s\n','');

% lag component (if applicable)

if d4~=0
fprintf('%s\n','theta4 (lag-specific component)');
fprintf(fid,'%s\n','theta4 (lag component)');
for ii=1:d4
values=[theta_median(d1+d2+d3+ii,1) theta_std(d1+d2+d3+ii,1) theta_lbound(d1+d2+d3+ii,1) theta_ubound(d1+d2+d3+ii,1)];
fprintf('%-35s %15.3f %15.3f %15.3f %15.3f\n',['lag ' int2str(ii) ' component'],values);
fprintf(fid,'%-35s %15.3f %15.3f %15.3f %15.3f\n',['lag ' int2str(ii) ' component'],values);
end
fprintf('%s\n','');
fprintf(fid,'%s\n','');
end

% exogenous component (if applicable)

if d5~=0
fprintf('%s\n','theta5 (exogenous variable component)');
fprintf(fid,'%s\n','theta5 (exogenous component)');
% initiate equation count
eqcount=0;
% initiate exogenous count
exocount=0;
for ii=1:d5
   if exocount==m
   exocount=0;
   end
   if exocount==0
   eqcount=eqcount+1;
   end
exocount=exocount+1;
values=[theta_median(d1+d2+d3+d4+ii,1) theta_std(d1+d2+d3+d4+ii,1) theta_lbound(d1+d2+d3+d4+ii,1) theta_ubound(d1+d2+d3+d4+ii,1)];
fprintf('%-35s %15.3f %15.3f %15.3f %15.3f\n',['equation ' int2str(eqcount) ', exogenous ' int2str(exocount) ' component'],values);
fprintf(fid,'%-35s %15.3f %15.3f %15.3f %15.3f\n',['equation ' int2str(eqcount) ', exogenous ' int2str(exocount) ' component'],values);
end
fprintf('%s\n','');
fprintf(fid,'%s\n','');
end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');



% display VAR stability results
eigmodulus=reshape(eigmodulus,p,N*n);
stabilityinfo1=['Roots of the characteristic polynomial (modulus):'];
fprintf('%s\n',stabilityinfo1);
fprintf(fid,'%s\n',stabilityinfo1);
for jj=1:p
temp=num2str(eigmodulus(jj,1),'%.3f');
   for kk=2:N*n
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



% display posterior for sigma
% reshape sigma
sigma_median=reshape(sigma_median,N*n,N*n);
% start displaying
sigmainfo=['sigma (residual covariance matrix): posterior estimates'];
fprintf('%s\n',sigmainfo);
fprintf(fid,'%s\n',sigmainfo);
% calculate the (integer) length of the largest number in sigma, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(sigma_median))))));
% add a separator, a potential minus sign, and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:N*n
temp=[];
   for jj=1:N*n
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
D=reshape(D_estimates,N*n,N*n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(D))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:N*n
temp=[];
   for jj=1:N*n
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
gamma=reshape(gamma_estimates,N*n,N*n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(D))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:N*n
temp=[];
   for jj=1:N*n
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
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

% finally display in-sample and forecast evaluation measures
% if forecast evaluation is activated and possible, display the results
if Feval==1 && Fcomp==1
panel5fprint(Units,N,n,endo,rss,r2,r2bar,RMSE,MAE,MAPE,Ustat,CRPS_estimates,S1_estimates,S2_estimates,stringdates3,Fstartdate,Fcenddate,Fcperiods,fid);

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




