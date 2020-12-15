function [Forecasteval]=bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref,dataValues, Psi_gibbs,sizetraining,data_exo_p, Fstartlocation,Fperiods, data_endo_a)



% function []=bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_estimates,names,endo,datapath)
% calculates, display and saves forecast evaluation results for a BVAR model
% inputs:  - matrix 'data_endo_c': matrix of endogenous data for the forecast evaluation period (i.e. period for which forecast is estimated and actual data exists)
%          - matrix 'data_endo_c_lags': lagged endogenous values to serve as initial conditions to the forecast evaluation period
%          - matrix 'data_exo_c': matrix of predicted data for the forecast period
%          - cell 'stringdates3': date strings for the forecast evaluation period (i.e. period for which forecast is estimated and actual data exists)
%          - string 'Fstartdate': start date of the forecasts
%          - string 'Fcenddate': end date of the forecat evaluation (i.e. period for which forecast is estimated and actual data exists)
%          - integer 'Fcperiods': number of periods for which forecast evaluation can be conducted (i.e.for which forecast is estimated and actual data exists)
%          - integer 'Fcomp': 0-1 value indicating if forecast evaluation is possible
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - cell 'forecast_estimates': lower bound, point estimates, and upper bound for the unconditional forecasts
%          - cell 'names': cell containing the excel spreadsheet labels (names and dates)
%          - cell 'endo': list of endogenous variables of the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none


% changed ad 2017-01-06 to store results
Forecasteval.RMSE=[];
Forecasteval.MAE=[];
Forecasteval.MAPE=[];
Forecasteval.Ustat=[];
Forecasteval.CRPS_estimates=[];
Forecasteval.S1_estimates=[];
Forecasteval.S2_estimates=[];


% first, note that forecast evaluation can only be conducted if there is some observable data after the beginning of the forecast
if Fcomp==1
    
    
    % preliminary task: obtain a matrix of forecasts over the common periods
    for ii=1:n
        forecast_c(:,ii)=forecast_estimates{ii,1}(2,1:Fcperiods)';
    end
    % then compute the matrix of forecast errors
    ferrors=data_endo_c-forecast_c;

    % compute first the sequential RMSE, from (1.8.11)
    
    % square the forecast error matrix entrywise
    sferrors=ferrors.^2;
    % sum entries sequentially
    sumsferrors=sferrors(1,:);
    for ii=2:Fcperiods
        sumsferrors(ii,:)=sumsferrors(ii-1,:)+sferrors(ii,:);
    end
    % divide by the number of forecast periods and take square roots to obtain RMSE
    for ii=1:Fcperiods
        Forecasteval.RMSE(ii,:)=((1/ii)*sumsferrors(ii,:)).^0.5;
    end
    
    
    
    % compute then the sequential MAE, from (1.8.12)
    
    % take the absolute value of the forecast error matrix
    absferrors=abs(ferrors);
    % sum entries sequentially
    sumabsferrors=absferrors(1,:);
    for ii=2:Fcperiods
        sumabsferrors(ii,:)=sumabsferrors(ii-1,:)+absferrors(ii,:);
    end
    % divide by the number of forecast periods to obtain MAE
    for ii=1:Fcperiods
        Forecasteval.MAE(ii,:)=(1/ii)*sumabsferrors(ii,:);
    end
    
    
    
    % compute the sequential MAPE, from (1.8.13)
    
    % divide entrywise by actual values and take absolute values
    absratioferrors=abs(ferrors./data_endo_c);
    % sum entries sequentially
    sumabsratioferrors=absratioferrors(1,:);
    for ii=2:Fcperiods
        sumabsratioferrors(ii,:)=sumabsratioferrors(ii-1,:)+absratioferrors(ii,:);
    end
    % divide by 100*(number of forecast periods) to obtain MAPE
    for ii=1:Fcperiods
        Forecasteval.MAPE(ii,:)=(100/ii)*sumabsratioferrors(ii,:);
    end
    
    
    
    % compute the Theil's inequality coefficient, from (1.8.14)
    
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
    Forecasteval.Ustat=Forecasteval.RMSE./(leftterm+rightterm);
    
    
    
    % now compute the continuous ranked probability score
    
    % create the cell storing the results
    Forecasteval.CRPS=cell(n,1);
    % loop over endogenous variables
    for ii=1:n
        % loop over forecast periods on which actual data is known
        for jj=1:Fcperiods
            % compute the continuous ranked probability score
            score=crps(forecast_record{ii,1}(:,jj),forecast_estimates{ii,1}(2,jj));
            Forecasteval.CRPS{ii,1}(1,jj)=score;
        end
    end
    Forecasteval.CRPS_estimates=(cell2mat(Forecasteval.CRPS))';
    
    
    
    
    % finally, consider the big piece: the computation of the log predictive score
    % this part implements algorithm a.8.1, described p 115 of technical guide
    % details of the procedure can be found p 111-115 of the technical guide
    
    
    % preliminary task: if there is a constant in the model, concatenate a column of ones to data_exo_c
    if const==1
        data_exo_c=[ones(Fcperiods,1) data_exo_c];
    end
    
    
    % create the cells storing the results
    S1=cell(n,1);
    S2=cell(n,1);
    
    size_estimation = size(data_endo_a,1);
    size_available  = size_estimation - sizetraining+p;
    
    
    forecast_local_mean = 0;
    % create first the cell storing the results
    forecast_record=cell(n,1);
    
    Mz=size(dataValues.Ppsi,1); %get the number of variables with survey local mean
    
    %create the state space matrices
    [KFSmatrices] = makeMatricesSLMfullSV(dataValues,p);
    Zv1=KFSmatrices.Zmatrix(Mz+1:end,:); %Meausrement equation matrix
    Rv1=KFSmatrices.R;                   %variance covariance of transition equation
    % Lv1=KFSmatrices.L;
    TmatrixV1=KFSmatrices.Tmatrix;       %State transition matrix

    Y=data_endo_a(end-p+1:end,:);

    for ll=1:It-Bu
        % step 2: draw beta and sigma
        beta=beta_gibbs(:,ll);
        sigma=reshape(sigma_gibbs(:,ll),n,n);
        
        
        for kk=1:n
           Psi(:,kk) = Psi_gibbs{1,kk}(Fstartlocation-sizetraining+p:Fstartlocation-sizetraining+2*p-1,ii);
        end 
        
        %now use the local mean to get the variables in deviation from the mean
        Ytilde = Y-Psi;

        B=reshape(beta,k,n);
        
        
        %and set the state transition equation matrix
        TmatrixV1(n+1:2*n,n+1:end) = B';
        
        %% get the unconditional forecast
        Yp=[]; %iniate forecast saving matrix
        
        %initate RHS
        % use the function lagx to obtain the matrix temp
        temp=lagx(Ytilde,p-1);
        % define the reduced regressor matrix X
        % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X only from the endogenous variables
        if isempty(data_exo_p)==1
            X=[temp(end,:)];
            % if there are exogenous vaiables, concatenate them next to the endogenous
        else
            X=[temp(end,:) data_exo_p(jj,:)];
        end
        
        %also concantenate the last in sample estimates of the local mean
        X=[Psi(end,:),X];
        
        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj=1:Fperiods
            
            %forecast the state space
            
            %forecast state space
            yp=TmatrixV1*X';
            
            % concatenate the transpose of yp to the top of Y
            Yp=[Yp,yp];
            
            %set X to yp and go for next iteration
            X = yp';
            % repeat until values are obtained for T+h
        end
        
        %use the state space matrices to ultimately get the level
        %forecast for the n variables (in levels)
        for kk=1:n
            fmat(:,kk)=(Zv1(kk,1:end)*Yp)';
        end
        
        
        % step 3: obtain mu, the mean vector, from (a.8.19)
        %temp=forecastsim(data_endo_c_lags,data_exo_c,beta,n,p,k,Fcperiods);
        mu=reshape(fmat',n*Fcperiods,1);
        
        
        % step 4: obtain upsilon, the covariance matrix, from (a.8.22)
        % recover the A1,A2,... matrices by reshaping beta
        temp=reshape(beta,k,n);
        temp=(temp(1:p*n,:))';
        Amatrices=cell(1,p);
        for ii=1:p
            Amatrices{1,ii}=temp(:,n*(ii-1)+1:n*ii);
        end
        % initiate upsilon with upsilon_1,1
        upsilon=cell(Fcperiods,Fcperiods);
        upsilon{1,1}=sigma;
        % complete the first column using (a.8.23)
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
                % define the mean
                mean=R*mu;
                % define the variance
                covar=R*upsilon*(R');
                % define the actual value
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
    
    
    % step 6: compute the log predictive score from (a.8.26)
    Forecasteval.S1_estimates=cell(n,1);
    Forecasteval.S2_estimates=cell(n,1);
    for ii=1:n
        for jj=1:Fcperiods
            Forecasteval.S1_estimates{ii,1}(1,jj)=log((1/(It-Bu))*sum(S1{ii,1}(:,jj)));
            Forecasteval.S2_estimates{ii,1}(1,jj)=log((1/(It-Bu))*sum(S2{ii,1}(:,jj)));
        end
    end
    Forecasteval.S1_estimates=(cell2mat(Forecasteval.S1_estimates))';
    Forecasteval.S2_estimates=(cell2mat(Forecasteval.S2_estimates))';
    
    
    
    
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
        values=Forecasteval.RMSE(1:Fcperiods,ii)';
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
        values=Forecasteval.MAE(1:Fcperiods,ii)';
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
        values=Forecasteval.MAPE(1:Fcperiods,ii)';
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
        values=Forecasteval.Ustat(1:Fcperiods,ii)';
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
        values=Forecasteval.CRPS_estimates(1:Fcperiods,ii)';
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
        values=Forecasteval.S1_estimates(1:Fcperiods,ii)';
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
        values=Forecasteval.S2_estimates(1:Fcperiods,ii)';
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














