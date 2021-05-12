function [favar]=favar_fevd(gamma_record,It,Bu,n,IRFperiods,FEVDband,favar)



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
npltXshck=favar.IRF.npltXshck;

%relevant loadings of restricted information variables
L=favar.L(favar.plotX_index,favar.IRF.plotXshock_index);
% gamma=gamma(:,favar.FEVD.plotXshock_index);
% % scale gamma, irf estimates are already scaled
%         for ii=1:npltX
%             for ll=1:npltXshck
%                 favar_gamma{ii}(:,ll)=L(ii,ll)*gamma(:,ll);
%             end
%         end

% create the first cell
temp=cell(npltX,npltXshck+1);

% start by filling the first column of every Tij matrix in the cell
% loop over rows of temp
for jj=1:npltX
   % loop over columns of temp
   for ii=1:npltXshck
   % square each element
   temp{jj,ii}(:,1)=favar.IRF.favar_irf_estimates{jj,ii}(:,1).^2;
   end
end
% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:npltX
   % loop over columns of temp
   for ii=1:npltXshck
      % loop over remaining columns
      for kk=2:IRFperiods
      % define the column as the square of the corresponding column in orthogonalised_irf_record
      % additioned to the value of the preceeding columns, which creates the cumulation
      temp{jj,ii}(:,kk)=favar.IRF.favar_irf_estimates{jj,ii}(:,kk).^2+temp{jj,ii}(:,kk-1);
      end
   end
end



% multiply each matrix in the cell by the variance of the structural shocks
% to do so, loop over simulations (rows of the Tij matrices)
for kk=1:It-Bu
% recover the covariance matrix of structural shocks gamma for this iteration
gamma=reshape(gamma_record(:,kk),n,n);

gamma=gamma(:,favar.IRF.plotXshock_index);
% scale gamma, irf estimates are already scaled
        for ii=1:npltX
            for ll=1:npltXshck
                favar_gamma{ii}(:,ll)=L(ii,ll)*gamma(:,ll);
            end
        end

% loop over rows of temp
for ii=1:npltX
% loop over columns of temp
   for jj=1:npltXshck
   % multiply column jj of the matrix by the variance of the structural shock
   temp{ii,jj}(1,:)=temp{ii,jj}(1,:)*favar_gamma{ii}(jj,jj);
   end
end
end

% obtain now the values for Ti, the (n+1)th matrix of each row
% loop over rows of temp
for ii=1:npltX
% start the summation over Tij matrices
temp{ii,npltXshck+1}=temp{ii,1};
   % sum over remaining columns
   for jj=2:npltXshck
   temp{ii,npltXshck+1}=temp{ii,npltXshck+1}+temp{ii,jj};
   end      
end

% create the output cell fevd_record
favar_fevd_record=cell(npltX,npltXshck);
% fill the cell
% loop over rows of fevd_estimates
for ii=1:npltX
   % loop over columns of fevd_estimates
   for jj=1:npltXshck
   % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
   favar_fevd_record{ii,jj}=temp{ii,jj}./temp{ii,npltXshck+1};
   end
end




%% create the FEVD estimates output
% create first the cell that will contain the estimates
favar_fevd_estimates=cell(npltX,npltXshck);

% for each variable and each variable contribution along with each period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:npltX
   % consider contributions in turn
   for jj=1:npltXshck
      % consider periods in turn
      for kk=1:IRFperiods
      % compute first the lower bound
      favar_fevd_estimates{ii,jj}(1,kk)=quantile(favar_fevd_record{ii,jj}(:,kk),(1-FEVDband)/2);
      % then compute the median
      favar_fevd_estimates{ii,jj}(2,kk)=quantile(favar_fevd_record{ii,jj}(:,kk),0.5);
      % finally compute the upper bound
      favar_fevd_estimates{ii,jj}(3,kk)=quantile(favar_fevd_record{ii,jj}(:,kk),1-(1-FEVDband)/2);
      end
   end
end




%save output
favar.FEVD.favar_fevd_estimates=favar_fevd_estimates;

% % % % finally, save on excel  
% % % if pref.results==1
% % % % create the cell that will be saved on excel
% % % fevd_estimates=fevd_estimates';
% % % fevdcell={};
% % % % build preliminary elements: space between the tables
% % % horzspace=repmat({''},2,3*n);
% % % vertspace=repmat({''},IRFperiods+3,1);
% % % % loop over variables (vertical dimension)
% % % for ii=1:n
% % % tempcell={};
% % %    % loop over shocks (horizontal dimension)
% % %    for jj=1:n
% % %    % create cell of fevd record for variable ii in response to shock jj
% % %    temp=['part of ' endo{ii,1} ' fluctuation due to ' endo{jj,1} ' shocks'];
% % %    fevd_ij=[temp {''};{''} {''};{''} {'median'};num2cell((1:IRFperiods)') num2cell((fevd_estimates{ii,jj})')];
% % %    tempcell=[tempcell fevd_ij vertspace];
% % %    end
% % % fevdcell=[fevdcell;horzspace;tempcell];
% % % end
% % % % trim
% % % fevdcell=fevdcell(3:end,1:end-1);
% % % % write in excel
% % %     xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],fevdcell,'FEVD','B2');
% % % end







