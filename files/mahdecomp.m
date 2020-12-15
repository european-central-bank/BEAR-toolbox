function [hd_record]=mahdecomp(beta_gibbs,delta_gibbs,D_record,strshocks_record,It,Bu,Y,X,Z,n,m,p,k1,k3,T)


% function [hd_record]=mahdecomp(beta_gibbs,delta_gibbs,sigma_gibbs,D_record,It,Bu,Y,X,Z,n,m,p,k1,k3,T)
% performs algortihm 3.2.1, and returns posterior draws from the historical decomposition of the data sample
% inputs:  - matrix 'beta_gibbs': the matrix recording the post-burn draws of beta
%          - matrix 'delta_gibbs': the matrix recording the post-burn draws of delta
%          - matrix 'D_record': the matrix recording the simulated values of the D matrix
%          - integer 'It': the total number of iterations run by the Gibbs sampler
%          - integer 'Bu': the number of initial iterations discared as burn-in sample
%          - matrix 'Y': the matrix of endogenous variables, defined in (3.5.10)
%          - matrix 'X': the matrix of endogenous regressors, defined in (3.5.10)
%          - matrix 'Z': the matrix of exogenous regressors, defined in (3.5.10)
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'p': the number of lags in the model
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
%          - integer 'k3': the number of coefficients related to the exogenous variables for each equation, in the reformulated model (3.5.5)
%          - integer 'T': the sample size, i.e. the number of time periods used to estimate the model
% outputs: - cell 'hd_record': the cell array containing records of simulated  hisotrical decompositions



% this function implements algorithm 3.2.1, adapted to the mean-adjusted VAR model



% preliminary tasks
% first create the hd_record and temp cells
hd_record=cell(n,n+1);
temp=cell(n,2);



% then initiate the Gibbs algorithm
for ii=1:It-Bu


% step 2: recover parameters
beta=beta_gibbs(:,ii);
B=reshape(beta,k1,n);
delta=delta_gibbs(:,ii);
Delta=reshape(delta,k3,n);
D=reshape(D_record(:,ii),n,n);


% step 3: obtain irfs and orthogonalised irfs
[~,ortirfmatrix]=mairfsim(B,D,p,n,T);


% step 5: compute the historical contribution of each shock
   % fill the Yhd matrices
   % loop over rows of temp
   for jj=1:n
      % loop over columns of temp
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




