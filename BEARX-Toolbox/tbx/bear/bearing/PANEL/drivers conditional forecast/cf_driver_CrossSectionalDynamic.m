function [cforecast_record,cforecast_estimates]  =  ...
   cf_driver_CrossSectionalDynamic(numCountries,numEndog,numExog,numLags,k,numFactors,cfconds,cfshocks,cfblocks,It,Bu,Fperiods,const,Xi,data_exo_p,theta_gibbs,B_gibbs,phi_gibbs,Zeta_gibbs,sigmatilde_gibbs,Fstartlocation,Ymat,rho,thetabar,gamma,CFt,Fband)
    
    % !!!! LJ NOTES
    % * CFt defines type of conditional forecast. Only 1 and 2 are allowed. 1 is for the case where the user specifies the shocks, 2 is for the case where the user specifies the blocks

    % * There was an issue with script that prepares cfconds, cfshocks and cfblocks. In the code they used str2double, while for other models (non-panel) they used str2num. The difference is that str2double returns NaN if the input is not a number, while str2num returns []. This caused the issue in the code, because later on they check if the input is empty, but they do not check if it is NaN. I have changed the code to use str2num and commited the changes to the repository. 

    % * cfconds, cfshocks, cfblocks are coming from the excel file. Initialy this is one table in the form [CC]_enodg_var_name, but then in the data preparation it is transformed into cube for panels without cross-country dependence, while for panels with cross-country dependence it stays in the plain table format. 

    % * cfconds defines which variables are going to be conditionally forecasted. This matrix is enough in the case of CFt  =  1, when all shocks can be used for conditional forecasts.

    % * cfshocks defines which shocks (order number) are used for conditional forecasts. There can be more than one shock used for conditional forecasts. In that case in the field multiple numbers can be entered separated by space. Eg. US GDP endogenous can be explained with GDP shock and Interest rate shock. In that case the field would be '1 3'. Important, if model is without cross-country dependence, then the shocks are defined for each country separately. This means that the numbering of the shocks is done for each country separately.

    % * cfblocks defines blocks of shocks. And in this order it will be forecasted. Same as for cfshocks, if model is without cross-country dependence, then the blocks are defined for each country separately. This means that the numbering of the blocks is done for each country separately.

    % * Ymat is like longY, 2D matrix with all endogenous/country variables

    % !!! END OF LJ NOTES

    % preliminary tasks: generate the matrix of predicted exogenous variables
    % if the constant has been retained, augment the matrices of exogenous (both actual and predicted) with a column of ones:
    if const == 1
    
        data_exo_p = [ones(Fperiods,1) data_exo_p];
        % if no constant was included, do nothing
    end

    % obtain the location of the final sample period before the beginning of the forecasts
    finalp = Fstartlocation-1;
    % obtain the value of ybarT
    ybarT = bear.vec(flipud(Ymat(finalp-numLags+1:finalp,:))');

    % start simulations
    for ii = 1:It-Bu


        % first recover the VAR coefficient values for each period
        % recover theta for the final period before forecast
        theta = theta_gibbs(:,ii,finalp);

        % then recover B
        B = reshape(B_gibbs(:,ii),numFactors,numFactors);
        
        % obtain its choleski factor as the square of each diagonal element
        cholB = diag(diag(B).^0.5);

        % obtain the values for theta for each forecast period
        % initiate the recording of theta values
        theta_iter = [];

        % loop over forecast periods
        for jj = 1:Fperiods

            % obtain a shock eta
            eta = cholB*mvnrnd(zeros(numFactors,1),eye(numFactors))';

            % update theta from its AR process
            theta = (1-rho)*thetabar+rho*theta+eta;

            % record
            theta_iter = [theta_iter theta];

        end

        % obtain similarly the value for sigma and D for each forecast period
        % recover sigmatilde
        sigmatilde = reshape(sigmatilde_gibbs(:,ii),numCountries*numEndog,numCountries*numEndog);

        % recover phi
        phi = phi_gibbs(1,ii);

        % initiate zeta
        zeta = Zeta_gibbs(finalp,ii);

        % initiate the recording of sigma values and D values
        sigma_iter = [];
        D_iter = [];
        gamma_iter = [];

        % loop over forecast periods
        for jj = 1:Fperiods

            % obtain a shock upsilon
            ups = normrnd(0,phi); 

            % update zeta from its law of motion
            zeta = gamma*zeta+ups;

            % update sigma
            sigma_iter(:,:,jj) = exp(zeta)*sigmatilde;

            % obtain the structural decomposition matrix
            D_iter(:,:,jj) = chol(bear.nspd(sigma_iter(:,:,jj)),'lower');

            % obtain the variance-covariance matrix of the structural disturbances (identity for a Choleski scheme)
            gamma_iter(:,:,jj) = eye(numCountries*numEndog);
        end

        % obtain the unconditional forecasts and the orthogonalised impulse response functions
        [fmat ortirfcell] = bear.panel6cfsim(theta_iter,D_iter,Xi,ybarT,data_exo_p,Fperiods,numCountries,numEndog,numExog,numLags,k);

        % obtain the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
        % if the user selected the basic setting (all the shocks are used)
        if CFt == 1
            eta = bear.shocksim3(cfconds,Fperiods,numCountries,numEndog,fmat,ortirfcell);
        % if instead the user selected the shock-specific setting
        elseif CFt == 2
            eta = bear.shocksim4(cfconds,cfshocks,cfblocks,Fperiods,numCountries,numEndog,gamma_iter,fmat,ortirfcell);
        end
        eta = reshape(eta,numCountries*numEndog,Fperiods);

        % obtain the conditional forecasts
        % loop over periods
        for jj = 1:Fperiods

            % compute shock contribution to forecast values
            % create a temporary vector of cumulated shock contributions
            temp = zeros(numCountries*numEndog,1);
            % loop over periods up the the one currently considered
            for kk = 1:jj

                temp = temp+ortirfcell{jj-kk+1,jj}(:,:)*eta(:,kk);

            end
            % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
            cdforecast(jj,:) = fmat(jj,:)+temp';

        end
        clear temp

        % record the results from current iteration in the cell cforecast_record
        % loop over variables
        for jj = 1:numCountries*numEndog

            % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
            % record these values in the corresponding matrix of cforecast_record
            cforecast_record{jj,1}(ii,:) = cdforecast(:,jj)';
            
        end


    % then go for next iteration
    end

    % obtain point estimates and credibility interval
    [cforecast_estimates] = bear.festimates(cforecast_record,numCountries*numEndog,Fperiods,Fband);


    % reorganise to obtain a record similar to that of the unconditional forecasts
    cforecast_record = reshape(cforecast_record,numEndog,1,numCountries);
    cforecast_estimates = reshape(cforecast_estimates,numEndog,1,numCountries);
end


































