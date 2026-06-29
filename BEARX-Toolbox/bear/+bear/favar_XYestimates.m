function [X_estimates,Y_estimates,favar]=favar_XYestimates(T,n,p,m,It,Bu,favar)
   % reshape the vectorised draws to their original form
   X_gibbs=reshape(favar.X_gibbs,T,n*p+m,It-Bu);
   Y_gibbs=reshape(favar.Y_gibbs,T,n,It-Bu);
%    FY_gibbs=reshape(favar.FY_gibbs,T,n,It-Bu);
%    L_gibbs=reshape(favar.L_gibbs,size(favar.L,1),n,It-Bu);
%    R2_gibbs=reshape(favar.R2_gibbs,favar.npltX,1,It-Bu);
   
% consider periods in turn
for ii=1:T
   % consider variables in turn
   for jj=1:n
   % compute the median
   Y_estimates(ii,jj)=quantile(Y_gibbs(ii,jj,:),0.5);
%    FY_estimates(jj,ii)=quantile(FY_gibbs(jj,ii,:),0.5);
   end
   for jj=1:n*p+m
   X_estimates(ii,jj)=quantile(X_gibbs(ii,jj,:),0.5);
   end
end

% we need this for some routines 
favar.bvarXY=1;