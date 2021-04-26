function [logval val]=mndensity(x,mu,sigma,k)


% function [logval val]=mndensity(x,mu,sigma,k)
% computes the density of the multivariate normal distribution
% uses the log of the density (a.2.1), split into several parts for computation ease
% inputs:  - vector 'x': the argument of the density function
%          - vector 'mu': the mean of the distribution
%          - matrix 'sigma': the covariance of the distribution
%          - integer 'k': the dimension of the argument vector
% outputs: - scalar 'logval': the log of the density value
%          - scalar 'val': the density value



temp(1,1)=-(k/2)*log(2*pi);
temp(2,1)=-0.5*log(det(sigma));
temp(3,1)=-0.5*(x-mu)'*(sigma\(x-mu));

% temp(3,1)=-0.5*(x-mu)'*inv(sigma)*(x-mu);

logval=sum(temp);
val=exp(logval);



