function []=olsfeval(data_endo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,n,forecast_estimates,names,endo,pref)



% function []=olsfeval(data_endo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,n,forecast_estimates,names,endo,datapath)
% calculates, display and saves forecast evaluation results for a OLS VAR model
% inputs:  - matrix 'data_endo_c': matrix of endogenous data for the forecast evaluation period (i.e. period for which forecast is estimated and actual data exists) 
%          - cell 'stringdates3': date strings for the forecast evaluation period (i.e. period for which forecast is estimated and actual data exists)
%          - string 'Fstartdate': start date of the forecasts
%          - string 'Fcenddate': end date of the forecat evaluation (i.e. period for which forecast is estimated and actual data exists)
%          - integer 'Fcperiods': number of periods for which forecast evaluation can be conducted (i.e.for which forecast is estimated and actual data exists)
%          - integer 'Fcperiods': number of periods for which forecast evaluation can be conducted (i.e.for which forecast is estimated and actual data exists)
%          - integer 'Fcomp': 0-1 value indicating if forecast evaluation is possible
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'forecast_estimates': lower bound, point estimates, and upper bound for the unconditional forecasts
%          - cell 'names': cell containing the excel spreadsheet labels (names and dates)
%          - cell 'endo': list of endogenous variables of the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none 



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


    end

end

fclose(fid);




