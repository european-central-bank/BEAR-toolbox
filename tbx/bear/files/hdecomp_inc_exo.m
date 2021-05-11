function [hd_record,favar]=hdecomp_inc_exo(beta_gibbs,D_record,It,Bu,Y,X,n,m,p,k,T,data_exo,exo,endo,const,IRFt,strctident,favar)



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

%% preliminary tasks

% number of identified shocks & create labels for the contributions
if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
    labels=endo;
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
    labels=strctident.signreslabels_shocks; % signreslabels
elseif IRFt==5
    identified=1; % one IV shock
    labels{identified,1}=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
end

% first create the hd_record and temp cells
contributors = n + 1 + length(exo) + 1 ; %variables + constant + exogenous + initial conditions
hd_record=cell(contributors+2,n);
HDstorage = cell(It-Bu,1);

D_gibbs=reshape(D_record,n,n,It-Bu);
% recall X and Y from the sampling process in this case, analogue to beta and sigma
if favar.FAVAR==1
    favar_HDstorage = cell(It-Bu,1);
    Xgibbs=reshape(favar.X_gibbs,size(X,1),size(X,2),It-Bu);
    Ygibbs=reshape(favar.Y_gibbs,size(Y,1),size(Y,2),It-Bu);
    Lgibbs=reshape(favar.L_gibbs,size(favar.L,1),size(favar.L,2),It-Bu);
    %relevant loadings of restricted information variables
    Lgibbs=Lgibbs(favar.plotX_index,:,:);
end

%% then initiate the Gibbs algorithm
for ii=1:It-Bu
    % step 2: recover parameters
    beta=beta_gibbs(:,ii);
    D=squeeze(D_gibbs(:,:,ii));
    
    if favar.FAVAR==1
        X=squeeze(Xgibbs(:,:,ii));
        Y=squeeze(Ygibbs(:,:,ii));
    end
    
    [hd_estimates]=hd_new_for_signres(const,exo,beta,k,n,p,D,m,T,X,Y,data_exo,IRFt,labels);
    HDstorage{ii,1}=hd_estimates;
    
    if favar.FAVAR==1 && favar.HD.plot==1
        L_g=squeeze(Lgibbs(:,:,ii));
        [favar,favar_hd_estimates]=favar_hdestimates(favar,hd_estimates,n,IRFt,endo,strctident,L_g);
        favar_HDstorage{ii,1}=favar_hd_estimates;
    end
end

%% reorganize historical decomposition
for ii=1:It-Bu %loop over draws
    for kk=1:contributors+2 %loop over contributors
        for ll=1:n %loop over variables
            hd_record{kk,ll}(ii,:) = HDstorage{ii,1}{kk,ll}(2,:);
        end
    end
end

if favar.FAVAR==1 && favar.HD.plot==1
    for ii=1:It-Bu %loop over draws
        for kk=1:contributors+2 %loop over contributors
            for ll=1:n %loop over variables
            for ww=1:favar.npltX
                favar_hd_record{kk,ll,ww}(ii,:)=favar_HDstorage{ii,1}{kk,ll,ww};
            end
            end
        end
    end
    % save output
    favar.HD.favar_hd_record=favar_hd_record;
end
