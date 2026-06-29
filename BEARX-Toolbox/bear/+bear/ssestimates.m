function [ss_estimates,ss_estimates_constant,ss_estimates_exogenous,ss_estimates_contribution_exo]=ssestimates(ss_record,n,T,cband)



% function [ss_estimates]=ssestimates(ss_record,n,T,cband)
% calculates the point estimate (median), lower bound and upper bound of the steady-state from the posterior distribution
% inputs:  - cell 'ss_record': record of the gibbs sampler draws for the steady-state
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - scalar 'cband': confidence level for VAR coefficients
% outputs: - cell 'ss_estimates': lower bound, point estimates, and upper bound for the steady-state 



% create first the cell that will contain the estimates
ss_estimates=cell(n,1);
ss_estimates_constant=cell(n,1);
ss_estimates_exogenous=cell(n,1);
ss_estimates_contribution_exo=cell(1,1);
% for each variable and each sample period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider sample periods in turn
   for jj=1:T
   % compute first the lower bound
   ss_estimates{ii,1}(1,jj)=quantile(ss_record{ii,1}(:,jj),(1-cband)/2);
   % then compute the median
   ss_estimates{ii,1}(2,jj)=quantile(ss_record{ii,1}(:,jj),0.5);    
   % finally compute the upper bound
   ss_estimates{ii,1}(3,jj)=quantile(ss_record{ii,1}(:,jj),(1-(1-cband)/2));
% % %    if m>1
% % %    % same for only the constant
% % %    ss_estimates_constant{ii,1}(1,jj)=quantile(ss_record_constant{ii,1}(:,jj),(1-cband)/2);
% % %    % then compute the median
% % %    ss_estimates_constant{ii,1}(2,jj)=quantile(ss_record_constant{ii,1}(:,jj),0.5);    
% % %    % finally compute the upper bound
% % %    ss_estimates_constant{ii,1}(3,jj)=quantile(ss_record_constant{ii,1}(:,jj),(1-(1-cband)/2));
% % %    % same for only the exogenous
% % %    ss_estimates_exogenous{ii,1}(1,jj)=quantile(ss_record_exogenous{ii,1}(:,jj),(1-cband)/2);
% % %    % then compute the median
% % %    ss_estimates_exogenous{ii,1}(2,jj)=quantile(ss_record_exogenous{ii,1}(:,jj),0.5);    
% % %    % finally compute the upper bound
% % %    ss_estimates_exogenous{ii,1}(3,jj)=quantile(ss_record_exogenous{ii,1}(:,jj),(1-(1-cband)/2));
% % %    % compute contribution from only the exogenous part
% % %    ss_estimates_contribution_exo{ii,1}(1,jj)=(quantile(ss_record_constant{ii,1}(:,jj),0.5)-quantile(ss_record{ii,1}(:,jj),0.5));
% % %    else
% % %    ss_estimates_constant=[];
% % %    ss_estimates_exogenous=[];
% % %    end
   end
end




















