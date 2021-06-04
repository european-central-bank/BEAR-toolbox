function [logval val]=iwdensity(sigma,S,alpha,n)



% function function [logval val]=iwdensity(sigma,S,alpha,n)
% computes the density (value and log value) of the inverse Wishart distribution 
% inputs:  - matrix 'sigma': 'true' variance-covariance matrix of VAR residuals, for the original Minnesota prior
%          - matrix 'S': scale matrix for sigma
%          - integer 'alpha': degrees of freedom for sigma
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - scalar 'logval': log of density value
%          - scalar 'val': density value


% calculates the density (a.2.10)

temp(1,1)=-(alpha*n/2)*log(2);
temp(2,1)=-mgamma(alpha/2,n);
temp(3,1)=(alpha/2)*log(det(S));
temp(4,1)=-((alpha+n+1)/2)*log(det(sigma));
temp(5,1)=-0.5*trace(sigma\S);

logval=sum(temp);
val=exp(logval);







