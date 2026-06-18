function [sigma_gibbs] = create_fcast_params(It,Bu,F_gibbs,phi_gibbs,L_gibbs,...
    gamma_gibbs,sbar,Fstartlocation,Fperiods,n)

sigma_gibbs = cell(Fperiods,1);

% then start simulations
% repeat the process a number of times equal to the number of simulations retained from Gibbs sampling
for ii = 1:It-Bu
    
    % draw F from its posterior distribution
    F = sparse(F_gibbs(:,:,ii));
    gamma = gamma_gibbs(ii,:)';
    
    % step 4: draw phi from its posterior
    phi = phi_gibbs(ii,:)';
    
    % also, compute the pre-sample value of lambda, the stochastic volatility process
    lambda = L_gibbs(Fstartlocation-1,:,ii)';
      
    % then generate forecasts recursively
    % for each iteration ii, repeat the process for periods T+1 to T+h
       for jj = 1:Fperiods
      
           % update lambda_t and obtain Lambda_t
           % loop over variables
              for kk=1:n
                lambda(kk,1) = gamma(kk,1)*lambda(kk,1)+phi(kk,1)^0.5*randn;
              end

           % obtain Lambda_t
           Lambda = sparse(diag(sbar.*exp(lambda)));
           
           % recover sigma_t and draw the residuals
           sigma_gibbs{jj,1}(:,:,ii) = full(F*Lambda*F');
    
       % step 8: repeat until values are obtained for T+h
       end
   
% step 9: repeat until It-Bu iterations are obtained
end

