function [beta_gibbs, sigma_gibbs_forecast, F_gibbs, L_gibbs, gamma_gibbs, phi_gibbs, sigma_gibbs_hist, lambda_t_gibbs ,sigma_t_gibbs, sbar, forecast_record]  = ...
    get_draws_and_forecast(data_endo_table,data_exo, opt)

%beta_gibbs
%F_gibbs: 3D array lower triangular matrix  where sigma_t_gibbs = F_gibbs*lambda_t_gibbs*F_gibbs'
%L_gibbs tv lambdas
%phi_gibbs: heteroscedasticity parameters (variance of lambdas)
%sigma_t_gibbs: see above
%lambda_t_gibbs: time varying diagonal matrix generating the
%heteroscedasticity (s_bar*exp(L) in the diagonal)
%sbar: scaling parameters, s
%sigma_gibbs F_gibbs*diag(sbar)*F_gibbs' so its fucking not the same sigma
%gibbs as for other BVARs, be careful!

data_endo_a = table2array(data_endo_table(:, 2:end)); %histrorical database
dates       = table2array(data_endo_table(:, 1));

%create matrices for VAR
[~, betahat, sigmahat, X, ~, Y, ~, ~, ~, n, m, p, T, k, q] = bear.olsvar(data_endo_a, data_exo, opt.const, opt.lags);

[arvar] = bear.arloop(data_endo_a, opt.const, p, n);
ar = ones(n,1)*opt.user_ar;

if m > 0
% individual priors 0 for default
    for ii=1:n
        for jj=1:m
            priorexo(ii,jj) = opt.priorsexogenous;
            tmp(ii,jj) = opt.lambda4;
        end
    end
opt.lambda4 = tmp;    
else
    for ii=1:n
        priorexo(ii,1) = opt.priorsexogenous;
    end
end

blockexo = [];
if  opt.bex==1
    [blockexo]=bear.loadbex(endo,pref);
end




%create matrices
[yt, Xt, Xbart] = bear.stvoltmat(Y,X,n,T); %create TV matrices
[beta0, omega0, I_o, omega, f0, upsilon0]=bear.stvol2prior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, opt.lambda5, n, m, p, T, k, q, opt.bex, blockexo, priorexo);


%run the sampler
[beta_gibbs, F_gibbs, gamma_gibbs, L_gibbs, phi_gibbs, sigma_gibbs_hist, lambda_t_gibbs, sigma_t_gibbs, sbar]=...
    bear.stvol2gibbs(Xbart, yt, beta0, omega0, opt.alpha0, opt.delta0, opt.gamma0, opt.zeta0, f0, upsilon0, betahat, sigmahat, I_o, omega, T, n, q, opt.It, opt.Bu, opt.pick, opt.pickf);

[Fstartlocation, Fperiods] = nw.get_fcast_rng(dates, opt);
Fstartlocation = Fstartlocation-opt.lags;


%% forecast
[sigma_gibbs_forecast] = sv.create_fcast_params(opt.It, opt.Bu, ...
                                        F_gibbs, phi_gibbs, L_gibbs, gamma_gibbs, sbar, Fstartlocation, Fperiods, n);

[forecast_record] = sv.forecast(data_endo_a, data_exo, beta_gibbs, sigma_gibbs_forecast, Fperiods, n, p, k, opt.const);


