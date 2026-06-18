function [sample, favar] = get_draws_new(data_endo_table, data_exo, informationdata, informationnames,opts, favar)

%% load data and get factors
data_endo_raw = table2array(data_endo_table(:,2:end));

[data_endo, favar] = favars.get_favar_endo(opts, data_endo_raw, favar, informationdata, informationnames);

%% getting X and Y matrices for gibbs sampler
[~, ~, ~, X, ~, Y, ~, ~, ~, n, m, p, T, k, q] = bear.olsvar(data_endo,data_exo,opts.const,opts.lags);

% individual priors 0 for default
for ii=1:n
    for jj=1:m+1
        priorexo(ii,jj) = opts.priorsexogenous;
        tmp(ii,jj) = opts.lambda4;
    end
end
opts.lambda4 = tmp;
%% variance from univariate OLS for priors
[arvar] = bear.arloop(data_endo,opts.const,p,n);

%% estimating the FAVAR
%create a vector for AR hyperparamters
ar = ones(n,1)*opts.ar;
    
[prep] = nw_favar.favar_nwprep(n,m,p,k,T,q,data_endo,ar,arvar,...
    opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,favar,X);

[sample, fv] = nw_favar.favar_nwsampler(opts.It,n,m,p,k,T,q,ar,...
    opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,opts.const,...
                    data_exo,favar,Y,X,prep);

thin=abs(round(favar.thin));
name_smpl = ["beta_gibbs","sigma_gibbs"];
for nm = name_smpl
    sample.(nm) = sample.(nm)(:,opts.Bu+1:end);
    if thin~=1
        sample.(nm)=sample.(nm)(:,thin:thin:end);
    end
end

name_smpl = ["X_gibbs","Y_gibbs","FY_gibbs","L_gibbs"];
for nm = name_smpl
    favar.(nm) = fv.(nm)(:,opts.Bu+1:end);
    if thin~=1
        favar.(nm)=favar.(nm)(:,thin:thin:end);
    end
end

opts.It=(1/thin)*opts.It;
opts.Bu=(1/thin)*opts.Bu;

end                   