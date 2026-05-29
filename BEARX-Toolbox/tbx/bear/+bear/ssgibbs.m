function [ss_record]=ssgibbs(n,m,p,k,X,beta_gibbs,It,Bu,favar)



% function [ss_record]=ssgibbs(n,m,p,k,X,beta_gibbs,It,Bu)
% runs the gibbs sampler to obtain draws from the posterior distribution of the steady-state
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
% outputs: - cell 'ss_record': record of the gibbs sampler draws for the steady-state 



% first create the cell storing the steady-state draws
ss_record=cell(n,1);

% Bgibbs=reshape(beta_gibbs,k,n,It-Bu);

% recall X and Y from the sampling process in this case, analogue to beta and sigma
if favar.FAVAR==1
    if isfield(favar,'bvarXY')==1
        bvarXY=1;
    Xgibbs=reshape(favar.X_gibbs,size(X,1),size(X,2),It-Bu);
    else
        bvarXY=0;
    end
else
    bvarXY=0;
end

% run the Gibbs sampler
for ii=1:It-Bu

% % draw beta from its posterior distribution
% % recover the coefficient matrices A1,...,Ap and C
% % first, calculate B and take its transpose BT
% BT=squeeze(Bgibbs(:,:,ii))';

% draw beta from its posterior distribution
beta=beta_gibbs(:,ii);

% recover the coefficient matrices A1,...,Ap and C
% first, calculate B and take its transpose BT
BT=reshape(beta,k,n)';

    if bvarXY==1
        X=squeeze(Xgibbs(:,:,ii));
    end

% estimate the summation term I-A1-...-Ap
summation=eye(n);
   for jj=1:p
   summation=summation-BT(:,(jj-1)*n+1:jj*n);
   end

% recover C
C=BT(:,end-m+1:end);

% now calculate the product of the inverse of the summation with C
product=summation\C;

% keep only the exogenous regressor part of X
X_exo=X(:,end-m+1:end)';

% compute the steady-state values from (a.7.6)
ssvalues=product*X_exo;

% record the value in the cell ss_record
% loop over variables
   for jj=1:n
   ss_record{jj,1}(ii,:)=ssvalues(jj,:);
   end

end



