function [struct_irf_record,D_record,gamma_record,favar]=irftrigstvol(F_gibbs,sbar,irf_record,It,Bu,IRFperiods,n,favar)






% create first the cell that will store the results from the simulations
struct_irf_record=cell(n,n);

% then because each sigma from the Gibbs algorithm is obtained from sigma=F*Lambda*F',
% the triangular factor is simply F, and the covariance matrix gamma is just Lambda
% hence start by computing Lambda
Lambda=diag(sbar);
gamma=Lambda;

% preallocate
D_record=zeros(n^2,It-Bu);
gamma_record=zeros(n^2,It-Bu);
psi=zeros(n,n);

% recall L from the sampling process in this case, analogue to beta and sigma
if favar.FAVAR==1 && favar.npltX>0
    FAVAR=1;
    npltX=favar.npltX;
    favar_struct_irf_record=cell(n,favar.npltX);
    Lgibbs=reshape(favar.L_gibbs,size(favar.L,1),size(favar.L,2),It-Bu);
    %relevant loadings of restricted information variables
    Lgibbs=Lgibbs(favar.plotX_index,:,:);
else
    FAVAR=0;
    npltX=0;
end

% repeat simulations a number of times equal to the number of simulations retained from Gibbs sampling
for ii=1:It-Bu


% obtain the triangular factorisation of sigma: the triangular factor is simply F
D=F_gibbs(:,:,ii);


% step 4: obtain orthogonalised IRFs
   % loop over periods
   for jj=1:IRFperiods

      % loop over vertical and horizontal dimensions to recover the responses of all the variables to all the shocks
      for kk=1:n
         for ll=1:n
         % recover the IRF matrix psi, representing the response of variable kk to shock ll at time horizon jj, for Gibbs iteration ii
         psi(kk,ll)=irf_record{kk,ll}(ii,jj);
         end
      end

   % compute the orthonalised irf matrix psitilde, as defined in (2.3.10)
   psi_tilde=psi*D;

      % record the results in the cell; here again, loop over vertical and horizontal dimensions
      for kk=1:n
         for ll=1:n
         struct_irf_record{kk,ll}(ii,jj)=psi_tilde(kk,ll);
         end
      end
      
              % compute IRFs for FAVAR plotX variables
        if FAVAR==1 && npltX>0
            for oo=1:npltX
                L=squeeze(Lgibbs(oo,:,ii));
                for ll=1:n
                    favar_struct_irf_record{ll,oo}(ii,jj)=L*psi_tilde(:,ll);
                end
            end
        end

   %go for next period
   end

% step 5: record values for D and gamma
D_record(:,ii)=D(:);
gamma_record(:,ii)=gamma(:);

% go for next iteration
end

% save
if FAVAR==1 && npltX>0
    favar.IRF.favar_irf_record=favar_struct_irf_record;
end
