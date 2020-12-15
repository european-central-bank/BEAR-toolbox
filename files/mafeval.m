function [RMSE,MAE,MAPE,Ustat,CRPS_estimates,S1_estimates,S2_estimates]=mafeval(data_endo_c,data_endo_c_lags,data_exo_c,data_exo_c_lags,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,m,p,k1,k3,It,Bu,beta_gibbs,delta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref)

% changed ad 2017-01-06 to store results
RMSE=[]
MAE=[]
MAPE=[]
Ustat=[]
CRPS_estimates=[]
S1_estimates=[]
S2_estimates=[]

% first, note that forecast evaluation can only be conducted if there is some observable data after the beginning of the forecast
if Fcomp==1


   % preliminary task: obtain a matrix of forecasts over the common periods
   for ii=1:n
   forecast_c(:,ii)=forecast_estimates{ii,1}(2,1:Fcperiods)';
   end
   % then compute the matrix of forecast errors
   ferrors=data_endo_c-forecast_c;



   % compute first the sequential RMSE, defined in (a.8.11)

   % square the forecast error matrix entrywise
   sferrors=ferrors.^2;
   % sum entries sequentially
   sumsferrors=sferrors(1,:);
   for ii=2:Fcperiods
   sumsferrors(ii,:)=sumsferrors(ii-1,:)+sferrors(ii,:);
   end
   % divide by the number of forecast periods and take square roots to obtain RMSE
   for ii=1:Fcperiods
   RMSE(ii,:)=((1/ii)*sumsferrors(ii,:)).^0.5;
   end



   % compute then the sequential MAE, defined in (a.8.12)

   % take the absolute value of the forecast error matrix
   absferrors=abs(ferrors);
   % sum entries sequentially
   sumabsferrors=absferrors(1,:);
   for ii=2:Fcperiods
   sumabsferrors(ii,:)=sumabsferrors(ii-1,:)+absferrors(ii,:);
   end
   % divide by the number of forecast periods to obtain MAE
   for ii=1:Fcperiods
   MAE(ii,:)=(1/ii)*sumabsferrors(ii,:);
   end



   % compute the sequential MAPE, defined in (a.8.13)

   % divide entrywise by actual values and take absolute values
   absratioferrors=abs(ferrors./data_endo_c);
   % sum entries sequentially
   sumabsratioferrors=absratioferrors(1,:);
   for ii=2:Fcperiods
   sumabsratioferrors(ii,:)=sumabsratioferrors(ii-1,:)+absratioferrors(ii,:);
   end
   % divide by 100*(number of forecast periods) to obtain MAPE
   for ii=1:Fcperiods
   MAPE(ii,:)=(100/ii)*sumabsratioferrors(ii,:);
   end



   % compute the Theil's inequality coefficient, defined in (a.8.14)

   % first compute the left term of the denominator
   % square entrywise the matrix of actual data
   sendo=data_endo_c.^2;
   % sum entries sequentially
   sumsendo=sendo(1,:);
   for ii=2:Fcperiods
   sumsendo(ii,:)=sumsendo(ii-1,:)+sendo(ii,:);
   end
   % divide by the number of forecast periods and take square roots
   for ii=1:Fcperiods
   leftterm(ii,:)=((1/ii)*sumsendo(ii,:)).^0.5;
   end
   % then compute the right term of the denominator
   % square entrywise the matrix of forecast values
   sforecasts=forecast_c.^2;
   % sum entries sequentially
   sumsforecasts=sforecasts(1,:);
   for ii=2:Fcperiods
   sumsforecasts(ii,:)=sumsforecasts(ii-1,:)+sforecasts(ii,:);
   end
   % divide by the number of forecast periods and take square roots
   for ii=1:Fcperiods
   rightterm(ii,:)=((1/ii)*sumsforecasts(ii,:)).^0.5;
   end
   % finally, compute the U stats
   Ustat=RMSE./(leftterm+rightterm);

   

   % now compute the continuous ranked probability score
   
   % create the cell storing the results
   CRPS=cell(n,1);
   % loop over endogenous variables
   for ii=1:n
      % loop over forecast periods on which actual data is known
      for jj=1:Fcperiods    
      % compute the continuous ranked probability score
      score=crps(forecast_record{ii,1}(:,jj),forecast_estimates{ii,1}(2,jj));
      CRPS{ii,1}(1,jj)=score;
      end
   end
   CRPS_estimates=(cell2mat(CRPS))';






   % finally, consider the big piece: the computation of the log predictive score
   % this part implements algorithm a.8.1, described p 115 of technical guide
   % details of the procedure can be found p 111-115 of the technical guide


   % preliminary task: if there is a constant in the model, concatenate a column of ones to data_exo_c
   if const==1
   data_exo_c=[ones(Fcperiods,1) data_exo_c];
   data_exo_c_lags=[ones(p,1) data_exo_c_lags];
   end


   % create the cells storing the results
   S1=cell(n,1);
   S2=cell(n,1);


   for ll=1:It-Bu
      % step 2: draw beta, Delta and sigma
      beta=beta_gibbs(:,ll);
      Delta=reshape(delta_gibbs(:,ll),k3,n);
      sigma=reshape(sigma_gibbs(:,ll),n,n);
      % reshape beta to obtain B
      B=reshape(beta,k1,n);

      
      % step 3: obtain mu, the mean vector
      temp=maforecastsim(data_endo_c_lags,data_exo_c_lags,data_exo_c,B,Delta,p,n,m,Fcperiods);
      mu=reshape(temp',n*Fcperiods,1);


      % step 4: obtain upsilon, the covariance matrix
      % recover the A1,A2,... matrices by reshaping beta
      temp=B';
      Amatrices=cell(1,p);
      for ii=1:p
      Amatrices{1,ii}=temp(:,n*(ii-1)+1:n*ii);
      end
      % initiate upsilon with upsilon_1,1
      upsilon=cell(Fcperiods,Fcperiods);
      upsilon{1,1}=sigma;
      % complete the first column  using (a.8.23)
      for ii=2:Fcperiods
      upsilon_ij=Amatrices{1,1}*upsilon{ii-1,1};
      summ=min(ii-1,p);
         for jj=2:summ
         upsilon_ij=upsilon_ij+Amatrices{1,jj}*upsilon{ii-jj,1};
         end
      upsilon{ii,1}=upsilon_ij;
      end
      % complete the first row, using symmetry
      for ii=2:Fcperiods
      upsilon{1,ii}=upsilon{ii,1}';
      end
      % now take care of the other columns
      for jj=2:Fcperiods
      % first complete the variance matrix (the diagonal one), using (a.8.24)
      upsilon_jj=sigma;
      summ=min(jj-1,p);
         for kk=1:summ
         upsilon_jj=upsilon_jj+Amatrices{1,kk}*upsilon{jj-kk,jj};
         end
      upsilon{jj,jj}=upsilon_jj;
      % then complete the rest of the column, using (a.8.23)
         for ii=jj+1:Fcperiods
         % initiate upsilon_ij
         upsilon_ij=Amatrices{1,1}*upsilon{ii-1,jj};
         % continue the summation
         summ=min(ii-1,p);
            for kk=2:summ
            upsilon_ij=upsilon_ij+Amatrices{1,kk}*upsilon{ii-kk,jj};
            end
         upsilon{ii,jj}=upsilon_ij;
         end
         % complete the corresponding row, using symmetry
         for kk=jj+1:Fcperiods
         upsilon{jj,kk}=upsilon{kk,jj}';
         end
      end
      upsilon=cell2mat(upsilon);


      % step 5: obtain the predictive density
      
      % first consider scenario 1 (forecast at period T+i)
      % loop over variables
      for ii=1:n
         % loop over periods
         for jj=1:Fcperiods
         % define R
         R=zeros(1,n*Fcperiods);
         R(1,n*(jj-1)+ii)=1;
         % define the mean vector
         mean=R*mu;
         % define the covariance matrix
         covar=R*upsilon*(R');
         % define the vector of actual values
         actual=data_endo_c(jj,ii);
         % determine the density
         [~,density]=mndensity(actual,mean,covar,1);
         % record the result
         S1{ii,1}(ll,jj)=density;
         end
      end
      % then consider scenario 2 (forecast from beginning until period T+i)
      % loop over variables
      for ii=1:n
      R=[];
         % loop over periods
         for jj=1:Fcperiods
         % define R
         R=[R;zeros(1,n*Fcperiods)];
         R(jj,n*(jj-1)+ii)=1;
         % define the mean vector
         mean=R*mu;
         % define the covariance matrix
         covar=R*upsilon*(R');
         % define the vector of actual values
         actual=data_endo_c(1:jj,ii);
         % determine the density
         [~,density]=mndensity(actual,mean,covar,jj);
         % record the result
         S2{ii,1}(ll,jj)=density;
         end
      end
   end


   % step 6: compute the log predictive score from (XXX.11)
   S1_estimates=cell(n,1);
   S2_estimates=cell(n,1);
   for ii=1:n
      for jj=1:Fcperiods
      S1_estimates{ii,1}(1,jj)=log((1/(It-Bu))*sum(S1{ii,1}(:,jj)));
      S2_estimates{ii,1}(1,jj)=log((1/(It-Bu))*sum(S2{ii,1}(:,jj)));
      end
   end
   S1_estimates=(cell2mat(S1_estimates))';
   S2_estimates=(cell2mat(S2_estimates))';


% if forecast evaluation is not possible, do not do anything
elseif Fcomp==0
end







% now, print the results and display them

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'at');


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


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
   for ii=1:n


   fprintf('%s\n','');
   fprintf(fid,'%s\n','');


   endoinfo=['Endogenous: ' endo{ii,1}];
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
   values=RMSE(1:Fcperiods,ii)';
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
   values=MAE(1:Fcperiods,ii)';
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
   values=MAPE(1:Fcperiods,ii)';
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
   values=Ustat(1:Fcperiods,ii)';
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

   
   label='CRPS:       ';
   values=CRPS_estimates(1:Fcperiods,ii)';
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

   
   label='Log score 1:';
   values=S1_estimates(1:Fcperiods,ii)';
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


   label='Log score 2:';
   values=S2_estimates(1:Fcperiods,ii)';
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

fclose(fid);














