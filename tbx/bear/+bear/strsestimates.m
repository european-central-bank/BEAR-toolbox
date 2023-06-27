function [strshocks_estimates]=strsestimates(strshocks_record,n,T,IRFband)






% create first the cell that will contain the estimates
strshocks_estimates=cell(n,1);

% for each variable and each sample period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider sample periods in turn
   for jj=1:T
   % compute first the lower bound
   strshocks_estimates{ii,1}(1,jj)=quantile(strshocks_record{ii,1}(:,jj),(1-IRFband)/2);
   % then compute the median
   strshocks_estimates{ii,1}(2,jj)=quantile(strshocks_record{ii,1}(:,jj),0.5);
   % finally compute the upper bound
   strshocks_estimates{ii,1}(3,jj)=quantile(strshocks_record{ii,1}(:,jj),(1-(1-IRFband)/2));
   end
end

