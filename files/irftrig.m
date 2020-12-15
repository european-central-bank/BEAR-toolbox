function [struct_irf_record,D_record,gamma_record,favar]=irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar)



% function [struct_irf_record D_record gamma_record]=irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,n)
% runs the gibbs sampler to obtain draws from the posterior distribution of IRFs, orthogonalised with a triangular factorisation scheme
% inputs:  - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - cell 'irf_record': record of the gibbs sampler draws for the IRFs
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - cell 'struct_irf_record': record of the gibbs sampler draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma



% this function implements algortihm 12.1



% create the cells that will store the results from the simulations
struct_irf_record=cell(n,n);
D_record=zeros(n^2,It-Bu);
gamma_record=zeros(n^2,It-Bu);
psi=zeros(n,n);
sigma_gibbs=reshape(sigma_gibbs,n,n,It-Bu);

% recall L from the sampling process in this case, analogue to beta and sigma
if favar.FAVAR==1 && favar.npltX>0
    FAVAR=1;
    npltX=favar.npltX;
    favar_struct_irf_record=cell(favar.npltX,n);
    Lgibbs=reshape(favar.L_gibbs,size(favar.L,1),size(favar.L,2),It-Bu);
    %relevant loadings of restricted information variables
    Lgibbs=Lgibbs(favar.plotX_index,:,:);
else
    FAVAR=0;
    npltX=0;
end

% step 1: repeat simulations a number of times equal to the number of simulations retained from Gibbs sampling
for ii=1:It-Bu
    
    % step 2: recover sigma
    sigma=squeeze(sigma_gibbs(:,:,ii));
    
    % step 3: obtain the triangular factorisation of sigma
    [D,gamma]=triangf(sigma);
    
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
                    favar_struct_irf_record{oo,ll}(ii,jj)=L*psi_tilde(:,ll);
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