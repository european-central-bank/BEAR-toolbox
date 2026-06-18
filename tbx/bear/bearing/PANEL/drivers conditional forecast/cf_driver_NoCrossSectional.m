function [nconds,cforecast_record,cforecast_estimates] = ...
   cf_driver_NoCrossSectional(numCountries,numEndog,numExog,numLags,k,q,cfconds,cfshocks,cfblocks,LongY_a,LongX_a,LongX_p,It,Bu,Fperiods,const,beta_gibbs,D_record,gamma_record,CFt,Fband)

% !!!! LJ NOTES
% * CFt defines type of conditional forecast. Only 1 and 2 are allowed. 1 is for the case where the user specifies the shocks, 2 is for the case where the user specifies the blocks

% * There was an issue with script that prepares cfconds, cfshocks and cfblocks. In the code they used str2double, while for other models (non-panel) they used str2num. The difference is that str2double returns NaN if the input is not a number, while str2num returns []. This caused the issue in the code, because later on they check if the input is empty, but they do not check if it is NaN. I have changed the code to use str2num and commited the changes to the repository. 

% * cfconds, cfshocks, cfblocks are coming from the excel file. Initialy this is one table in the form [CC]_enodg_var_name, but then in the data preparation it is transformed into cube for panels without cross-country dependence, while for panels with cross-country dependence it stays in the plain table format. 

% * cfconds defines which variables are going to be conditionally forecasted. This matrix is enough in the case of CFt = 1, when all shocks can be used for conditional forecasts.

% * cfshocks defines which shocks (order number) are used for conditional forecasts. There can be more than one shock used for conditional forecasts. In that case in the field multiple numbers can be entered separated by space. Eg. US GDP endogenous can be explained with GDP shock and Interest rate shock. In that case the field would be '1 3'. Important, if model is without cross-country dependence, then the shocks are defined for each country separately. This means that the numbering of the shocks is done for each country separately.

% * cfblocks defines blocks of shocks. And in this order it will be forecasted. Same as for cfshocks, if model is without cross-country dependence, then the blocks are defined for each country separately. This means that the numbering of the blocks is done for each country separately.

% !!! END OF LJ NOTES



% initiate the cell recording the Gibbs sampler draws
cforecast_record = {};
cforecast_estimates = {};

% because conditional forecasts can be computed for many (potentially all) units, loop over units
for cc = 1:numCountries

   % check wether there are any conditions on unit ii
   temp = cfconds(:,:,cc);
   nconds(cc,1) = numel(temp(cellfun(@(x) any(~isempty(x)),temp)));

   % if there are conditions
   if nconds(cc,1) ~= 0

      % prepare the elements for conditional forecast estimation, depending on the type of conditional forecasts
      temp1 = cfconds(:,:,cc);

      if CFt == 1
         temp2 = {};
         temp3 = [];
      elseif CFt == 2
         temp2 = cfshocks(:,:,cc);
         temp3 = cfblocks(:,:,cc);
      end

      data_endo_a = LongY_a(:,:,cc);
      data_exo_a = LongX_a;
      data_exo_p = LongX_p;

      % start conditional forecast
      % preliminary tasks: generate the matrix of predicted exogenous variables
      % if the constant has been retained, augment the matrices of exogenous (both actual and predicted) with a column of ones:
      if const == 1
         data_exo_a = [ones(size(data_endo_a,1),1) data_exo_a];
         data_exo_p = [ones(Fperiods,1) data_exo_p];
      % if no constant was included, do nothing
      end
   
   
      % start simulations
      for ii = 1:It-Bu
      
         % step 1: attribute values for beta, D and gamma
         beta = beta_gibbs(:,ii);
         D = reshape(D_record(:,ii),numEndog,numEndog);
         gamma = reshape(gamma_record(:,ii),numEndog,numEndog);
         
         % step 2: compute regular forecasts for the data (without shocks)
         fmat = bear.forecastsim(data_endo_a,data_exo_p,beta,numEndog,numLags,k,Fperiods);
      
         % step 3: compute IRFs and orthogonalised IRFs matrices
         [~,ortirfmat] = bear.irfsim(beta,D,numEndog,numExog,numLags,k,Fperiods);
      
         % step 4: obtain the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
         % if the user selected the basic setting (all the shocks are used)
         if CFt == 1

            eta = bear.shocksim1(cfconds,Fperiods,numEndog,fmat,ortirfmat);
            % if instead the user selected the shock-specific setting

         elseif CFt == 2

            eta = bear.shocksim2(cfconds,cfshocks,cfblocks,Fperiods,numEndog,gamma,fmat,ortirfmat);

         end

         eta = reshape(eta,numEndog,Fperiods);
      
         % step 5: obtain the conditional forecasts
         % loop over periods
         for jj = 1:Fperiods

            % compute shock contribution to forecast values
            % create a temporary vector of cumulated shock contributions
            temp = zeros(numEndog,1);
            % loop over periods up the the one currently considered

            for kk = 1:jj

               temp = temp + ortirfmat(:,:,jj-kk+1)*eta(:,kk);

            end

            % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
            cdforecast(jj,:) = fmat(jj,:) + temp';
         end
         clear temp
      
      
         % step 6: record the results from current iteration in the cell cforecast_record
         % loop over variables
         for jj = 1:numEndog

            % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
            % record these values in the corresponding matrix of cforecast_record
            cf_record{jj,1}(ii,:) = cdforecast(:,jj)';
            strsh_record{jj,1}(ii,:) = eta(jj,:);
            
         end
      
      
      % then go for next iteration
      end

      cforecast_record(:,:,cc) = cf_record;
      strshocks_record(:,:,cc) = strsh_record;

      % then obtain point estimates and credibility intervals
      cforecast_estimates(:,:,cc) = bear.festimates(cforecast_record(:,:,cc),numEndog,Fperiods,Fband);

   % if there are no conditions, return empty elements
   elseif nconds(cc,1) == 0
       cforecast_record(:,:,cc) = cell(numEndog,1);
       cforecast_estimates(:,:,cc) = cell(numEndog,1);
   end
end


































