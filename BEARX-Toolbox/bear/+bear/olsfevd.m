function [fevd_estimates]=olsfevd(irf_estimates,IRFperiods,gamma,n)



% function [fevd_estimates]=olsfevd(irf_estimates,IRFperiods,gamma,n,endo,datapath)
% computes and displays fevd values for the OLS VAR model
% inputs:  - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs  
%          - integer 'IRFperiods': number of periods for IRFs
%          - matrix 'gamma': structural disturbance variance-covariance matrix (defined p 48 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: - cell 'fevd_estimates': lower bound, point estimates, and upper bound for the FEVD 



% this function implements the procedure described p55-56


% preliminary tasks
% create the first cell
temp=cell(n,n+1);

% start by filling the first column of every Tij matrix in the cell
% loop over rows of temp
for jj=1:n
   % loop over columns of temp
   for ii=1:n
   % square each element
   temp{jj,ii}(:,1)=irf_estimates{jj,ii}(:,1).^2;
   end
end
% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:n
   % loop over columns of temp
   for ii=1:n
      % loop over remaining columns
      for kk=2:IRFperiods
      % define the column as the square of the corresponding column in orthogonalised_irf_record
      % additioned to the value of the preceeding columns, which creates the cumulation
      temp{jj,ii}(:,kk)=irf_estimates{jj,ii}(:,kk).^2+temp{jj,ii}(:,kk-1);
      end
   end
end
% multiply each matrix in the cell by the variance of the structural shocks
% loop over rows of temp
for ii=1:n
% loop over columns of temp
   for jj=1:n
   % multiply column jj of the matrix by the variance of the structural shock
   temp{ii,jj}(1,:)=temp{ii,jj}(1,:)*gamma(jj,jj);
   end
end

% obtain now the values for Ti, the (n+1)th matrix of each row
% loop over rows of temp
for ii=1:n
% start the summation over Tij matrices
temp{ii,n+1}=temp{ii,1};
   % sum over remaining columns
   for jj=2:n
   temp{ii,n+1}=temp{ii,n+1}+temp{ii,jj};
   end      
end

% create the output cell fevd_record
fevd_estimates=cell(n,n);
% fill the cell
% loop over rows of fevd_estimates
for ii=1:n
   % loop over columns of fevd_estimates
   for jj=1:n
   % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
   fevd_estimates{ii,jj}=temp{ii,jj}./temp{ii,n+1};
   end
end



