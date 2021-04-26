function [hd_record]=hdecomp_stvol4(beta_gibbs,D_record,It,Bu,YincLags,n,m,p,k,T, data_exo, exo, Psi_gibbs, strctident, IRFt)



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

signreslabels_shocks = strctident.signreslabels_shocks ;
% preliminary tasks
% first create the hd_record and temp cells
contributors = n + 1 + length(exo) + 1 ; %variables + constant + exogenous + initial conditions 
hd_record=cell(contributors+2,n); 
temp=cell(n,2);
hd_estimates2=cell(contributors+2,n); %shocks+constant+initial values+exogenous+unexplained+to be explained by shocks only
HDstorage = cell(It-Bu,1);
%reorganiye Psi_gibbs
for yyy=1:It-Bu
    for kkk=1:n 
Psi_gibbs_new(:,kkk,yyy) = Psi_gibbs{1,kkk}(:,yyy);
    end
end 

% then initiate the Gibbs algorithm
parfor ii=1:It-Bu


% step 2: recover parameters
beta=beta_gibbs(:,ii);
D=reshape(D_record(:,ii),n,n);

Psidraw = Psi_gibbs_new(:,:,ii);
%create the vector Ydraw by subtracting the local mean from the data
Ypsi = YincLags(p+1:end,:)-Psidraw(p+1:end,:);
%ultimately create the RHS and LHS of the demeaned data VAR
temp=lagx(Ypsi,p);
% to build X, take off the n initial columns of current data
Xdraw=[temp(:,n+1:end)];
Ydraw=temp(:,1:n);
Psidrawcut = Psidraw(2*p:end,:);
%decompose the data into trend and cycle and further decomposes the cycle
%[hd_estimates] = hd_for_signres_stvol4(0,beta,k,n,p,D,m,T,Xdraw,Ydraw, data_exo, contributors, hd_estimates2, Psidrawcut, YincLags(2*p+1:end,:));
[hd_estimates] = hd_for_signres_stvol4(0,exo,beta,k,n,p,D,m,T,Xdraw,Ydraw,data_exo,IRFt,signreslabels_shocks, Psidrawcut, YincLags(2*p+1:end,:))
HDstorage{ii,1}=hd_estimates;
end

%reorganize historical decomposition
for ii=1:It-Bu %loop over draws %%%%% How should Acc be definded?
 for kk=1:contributors+2 %loop over contributors
     for ll=1:n %loop over variables
    hd_record{kk,ll}(ii,:) = HDstorage{ii,1}{kk,ll}; %%%%% HDstorage ?
     end 
  end
end
end

