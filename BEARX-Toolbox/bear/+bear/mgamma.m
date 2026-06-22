function [logval val]=mgamma(a,n)



% function [logval val]=mgamma(a,n)
% computes the value of the multivariate gamma function, defined in (a.2.11)
% inputs:  - scalar 'a': argument of the function
%          - integer 'n': dimension of the function
% outputs: - scalar 'logval': log of the data density value 
%          - scalar 'val': data density value



const=(n*(n-1)/4)*log(pi);

for jj=1:n
temp(jj,1)=gammaln(a+0.5*(1-jj));
end

logval=const+sum(temp);
val=exp(logval);