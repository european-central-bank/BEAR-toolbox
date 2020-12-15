function [hd_record]=hdecomp(beta_gibbs,D_record,strshocks_record,It,Bu,Y,X,n,m,p,k,T)



% function [hd_record]=hdecomp(beta_gibbs,sigma_gibbs,D_record,It,Bu,Y,X,n,m,p,k,T)
% runs the gibbs sampler to obtain draws from the posterior distribution of historical decomposition
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
% outputs: - cell 'hd_record': record of the gibbs sampler draws for the historical decomposition



% this function implements algorithm 3.2.1


% preliminary tasks
% first create the hd_record and temp cells
hd_record=cell(n,n+1);
temp=cell(n,2);



% then initiate the Gibbs algorithm
for ii=1:It-Bu


% step 2: recover parameters
beta=beta_gibbs(:,ii);
D=reshape(D_record(:,ii),n,n);


% step 3: obtain irfs and orthogonalised irfs
[~,ortirfmatrix]=irfsim(beta,D,n,m,p,k,T);


% step 5: compute the historical contribution of each shock
   % fill the Yhd matrices
   % loop over variables
   for jj=1:n
      % loop over shocks
      for kk=1:n
      % create the virf and vshocks vectors (shocks correspond to step 4)
         for ll=1:T
         virf(ll,1)=ortirfmatrix(jj,kk,ll);
         end
      vshocks=strshocks_record{kk,1}(ii,:)';
         % loop over sample periods
         for ll=1:T
         hd_record{jj,kk}(ii,ll)=virf(1:ll,1)'*flipud(vshocks(1:ll,1));
         end
      end
   end


% then go for next Gibbs iteration
end




% step 6: compute the contributions of deterministic variables
% loop over rows of temp/hd_record
for ii=1:n
% fill the Ytot matrix in temp
% initial condition
temp{ii,1}=hd_record{ii,1};
   % sum over the remaining columns of hd_record
   for jj=2:n
   temp{ii,1}=temp{ii,1}+hd_record{ii,jj};
   end
% fill the Y matrix in temp
temp{ii,2}=repmat(Y(:,ii)',It-Bu,1);
% fill the Yd matrix in hd_record
hd_record{ii,n+1}=temp{ii,2}-temp{ii,1};
% go for next variable
end




