function [strshocks_estimates,irf_estimates,D_estimates,gamma_estimates,favar] = run_irf(Y,X,beta_gibbs, sigma_gibbs,opts, favar)

%get size of the matrices
n = size(Y,2);
T = size(Y,1);
[q , ~]    = size(beta_gibbs);
k = q/n;
p = opts.lags;
m = k - n*p;

%% BLOCK 4: FIRFS

[irf_record]=bear.irf(beta_gibbs,opts.It,opts.Bu,opts.IRFperiods,n,m,p,k);

% If IRFs have been set to an SVAR with Cholesky identification (IRFt=2):

% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record, D_record, gamma_record,favar]=bear.irfchol(sigma_gibbs,irf_record,opts.It,opts.Bu,opts.IRFperiods,n,favar);
% compute first the empirical posterior distribution of the structural shocks

[strshocks_record]=bear.strshocks(beta_gibbs,D_record,Y,X,n,k,opts.It,opts.Bu,favar);

% compute posterior estimates

[strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,opts.IRFband);

% bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);

[irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates(struct_irf_record,n,opts.IRFperiods,opts.IRFband,opts.IRFt,D_record,gamma_record,favar);
 
    