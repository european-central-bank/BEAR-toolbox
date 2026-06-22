function [bhat sigmahatb sigmahat]=panel1estimates(X,Y,N,n,q,k,T)








% obtain an estimate of the VAR coefficients
% initiate the betahat vector
betahat=[];
% initiate the sum of the beta_i vectors and sigma_i matrices
betasum=zeros(q,1);
sigmasum=zeros(n,n);
% loop over units
for ii=1:N
% obtain Yi and Xi
Xi=X(:,:,ii);
Yi=Y(:,:,ii);
% estimate the VAR coefficients for this unit
Bhati=(Xi'*Xi)\(Xi'*Yi);
betahat(:,:,ii)=Bhati(:);
% estimate the residuals for this unit
EPShati=Yi-Xi*Bhati;
EPShat(:,:,ii)=EPShati;
% estimate the variance-covariance matrix for this unit and add to summation
sigmahati=(1/(T-k-1))*EPShati'*EPShati;
sigmasum=sigmasum+sigmahati;
% add the betahat value to the sum
betasum=betasum+betahat(:,:,ii);
end

% estimate bhat and sigmahat
bhat=(1/N)*betasum;
sigmahat=(1/N)*sigmasum;

% eventually estimate sigmab, the variance covariance matrix of the bhat vector of coefficients
sigmahatb=zeros(q,q);
for ii=1:N
sigmahatb=(betahat(:,1,ii)-bhat)*(betahat(:,1,ii)-bhat)';
end
sigmahatb=(1/(N*(N-1)))*sigmahatb;






























