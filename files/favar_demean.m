function [XC]=favar_demean(X)
% function for demeaning the data (applicable to stationary data) 
% demean each column of X.
T=size(X,1);              % Size of matrix of factor data
XC = X - ones(T,1)*(sum(X)/T); % de-meaning (much faster than MEAN with a FOR loop

%XC=X-repmat(mean(X),size(X,1),1);