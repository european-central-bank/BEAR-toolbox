function [favar]=favar_olsfevd(IRFperiods,gamma,favar,n,IRFt,strctident)



% function [fevd_estimates]=olsfevd(irf_estimates,IRFperiods,gamma,n,endo,datapath)
% computes and displays fevd values for the OLS VAR model
% inputs:  - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs  
%          - integer 'IRFperiods': number of periods for IRFs
%          - matrix 'gamma': structural disturbance variance-covariance matrix (defined p 48 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: - cell 'fevd_estimates': lower bound, point estimates, and upper bound for the FEVD 



% preliminary tasks
npltX=favar.npltX;

if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions+IV
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+IV)
elseif IRFt==5
    identified=1; % one IV shock
end

% load IRFs
favar_irf_estimates=favar.IRF.favar_irf_estimates;

% relevant loadings of restricted information variables
L=favar.L(favar.plotX_index,:);

% scale gamma, irf estimates are already scaled
        for ii=1:npltX
            for ll=1:identified
                favar_gamma{ii}(:,ll)=L(ii,ll)*gamma(:,ll);
            end
        end

% create the first cell
temp=cell(npltX,identified+1);

% start by filling the first column of every Tij matrix in the cell
% loop over rows of temp
for jj=1:npltX
   % loop over columns of temp
   for ii=1:identified
   % square each element
   temp{jj,ii}(:,1)=favar_irf_estimates{jj,ii}(:,1).^2;
   end
end
% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:npltX
   % loop over columns of temp
   for ii=1:identified
      % loop over remaining columns
      for kk=2:IRFperiods
      % define the column as the square of the corresponding column in orthogonalised_irf_record
      % additioned to the value of the preceeding columns, which creates the cumulation
      temp{jj,ii}(:,kk)=favar_irf_estimates{jj,ii}(:,kk).^2+temp{jj,ii}(:,kk-1);
      end
   end
end
% multiply each matrix in the cell by the variance of the structural shocks
% loop over rows of temp
for ii=1:npltX
% loop over columns of temp
   for jj=1:identified
   % multiply column jj of the matrix by the variance of the structural shock
   temp{ii,jj}(1,:)=temp{ii,jj}(1,:)*favar_gamma{ii}(jj,jj);
   end
end


% obtain now the values for Ti, the (n+1)th matrix of each row
% loop over rows of temp
for ii=1:npltX
% start the summation over Tij matrices
temp{ii,identified+1}=temp{ii,1};
   % sum over remaining columns
   for jj=2:identified
   temp{ii,identified+1}=temp{ii,identified+1}+temp{ii,jj};
   end      
end

% create the output cell fevd_record, scale the shocks with R2 in spirit of BBE (2005)
favar_fevd_estimates=cell(npltX,identified);
R2=favar_R2(favar.X(:,favar.plotX_index),favar.FY,favar.L,favar.plotX_index);
% fill the cell
% loop over rows of fevd_estimates
for ii=1:npltX
    % load the R2 to determine the "true" share of variance explained
    scale=R2(ii);
    shocks=[];
   % loop over columns of fevd_estimates
   for jj=1:identified
   % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
   shock=(temp{ii,jj}./temp{ii,identified+1})*scale;
   favar_fevd_estimates{ii,jj}=shock;
   % save shocks to compute residual
   shocks(:,:,jj)=shock;
   end
   % finally add the idiosyncratic component (residual)
   favar_fevd_estimates{ii,jj+1}=1-sum(shocks,3);
end

%save output
favar.FEVD.favar_fevd_estimates=favar_fevd_estimates;

