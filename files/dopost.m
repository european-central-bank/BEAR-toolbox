function [Bcap betacap Scap alphacap phicap alphatop]=dopost(X,Y,T,k,n)






% generate first the OLS estimates
Bcap=(X'*X)\X'*Y;

% vectorise to obtain betabar
betacap=Bcap(:);

% then generate the inverse Wishart elements
% generate Scap
Scap=(Y-X*Bcap)'*(Y-X*Bcap);
alphacap=T-k;


% finally, generate the matrix student parameters
C=trns(chol(nspd(X'*X),'Lower'));
invC=C\speye(k);
phicap=invC*invC';
alphatop=T-n-k+1;







