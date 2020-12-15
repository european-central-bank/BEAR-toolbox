function [fevd_record]=fevd_ols_IV(struct_irf_record,gamma_record,It,Bu,IRFperiods,n)


% function [fevd_record]=fevd(struct_irf_record,gamma_record,It,Bu,IRFperiods,n)
% runs the gibbs sampler to obtain draws from the posterior distribution of FEVD
% inputs:  - cell 'struct_irf_record': record of the gibbs sampler draws for the orthogonalised IRFs
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - cell 'fevd_record': record of the gibbs sampler draws for the FEVD


It=3;
Bu=0;

% this function implements algorithm 3.1.1



% preliminary tasks

% define the time horizon of FEVD as that of IRFs
FEVDperiods=IRFperiods;

% create the first cell
temp=cell(n,n+1);



% now prepare the evaluation of (3.1.13)
% start by filling the first column of every Tij matrix in the cell
% loop over rows of temp
for jj=1:n
   % loop over columns of temp
   for ii=1:n
   % square each IRF element
   temp{jj,ii}(:,1)=struct_irf_record{jj,ii}(:,1).^2;
   end
end





% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:n

   % loop over columns of temp
   for ii=1:n

      % loop over remaining columns
      for kk=2:FEVDperiods

      % define the column as the square of the corresponding column in orthogonalised_irf_record
      % additioned to the value of the preceeding columns, which creates the cumulation
      temp{jj,ii}(:,kk)=struct_irf_record{jj,ii}(:,kk).^2+temp{jj,ii}(:,kk-1);

      end
   end
end


% multiply each matrix in the cell by the variance of the structural shocks
% to do so, loop over simulations (rows of the Tij matrices)
for jj=1:It-Bu
% recover the covariance matrix of structural shocks gamma for this iteration
gamma=reshape(gamma_record,n,n);
% loop over rows of temp
   for ii=1:n
   % loop over columns of temp
      for kk=1:n
      % multiply row jj of the matrix by the variance of the structural shock
      temp{ii,kk}(jj,:)=temp{ii,kk}(jj,:)*gamma(kk,kk);
      end
   end
% then go for next iteration
end




% obtain now the values for Ti, the (n+1)th matrix of each row

% loop over rows of temp
for jj=1:n

% start the summation over Tij matrices
temp{jj,n+1}=temp{jj,1};
   % sum over remaining columns
   for ii=2:n
   temp{jj,n+1}=temp{jj,n+1}+temp{jj,ii};
   end      
end


% create the output cell fevd_record
fevd_record=cell(n,n);


% fill the cell
% loop over rows of fevd_record
for jj=1:n
   % loop over columns of fevd_record
   for ii=1:n
   % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
   fevd_record{jj,ii}=temp{jj,ii}./temp{jj,n+1};
   end
end













