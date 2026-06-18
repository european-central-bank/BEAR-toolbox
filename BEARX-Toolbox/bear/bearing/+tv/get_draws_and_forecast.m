function [beta_gibbs_forecast, beta_gibbs_hist, omega_gibbs, sigma_gibbs_forecast, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs_hist, lambda_t_gibbs ,sigma_t_gibbs, sbar, forecast_record]  = ...
    get_draws_and_forecast(data_endo_table,data_exo, opt)

%beta_gibbs_hist: 3D array for beta draws
%omega_gibbs: covriance matrix for the RW process of betas
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
[~, betahat, sigmahat, X, ~, Y, ~, ~, ~, n, ~, p, T, k, q] = bear.olsvar(data_endo_a, data_exo, opt.const, opt.lags);

[arvar] = bear.arloop(data_endo_a, opt.const, p, n);

%create matrices
[yt, y, ~, Xbart, Xbar] = bear.tvbvarmat(Y, X, n, q, T); %create TV matrices
[chi, psi, kappa, ~, H, I_tau, G, I_om, f0, upsilon0] = bear.tvbvar2prior(arvar, n, q, T, opt.gamma);

%run the sampler
[beta_gibbs_hist, omega_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs_hist, lambda_t_gibbs, sigma_t_gibbs, sbar]...
         = bear.tvbvar2gibbs(G, sigmahat, T, chi, psi, kappa, betahat, q, n, ...
                opt.It, opt.Bu, I_tau, I_om, H, Xbar, y, opt.alpha0, yt, Xbart, upsilon0, f0, opt.delta0, opt.gamma, opt.pick, opt.pickf);


[Fstartlocation, Fperiods] = nw.get_fcast_rng(dates, opt);
Fstartlocation = Fstartlocation-opt.lags;
%% forecast
[beta_gibbs_forecast, sigma_gibbs_forecast] = tv.create_fcast_params(opt.It, opt.Bu, beta_gibbs_hist, omega_gibbs, ...
                                        F_gibbs, phi_gibbs, L_gibbs, opt.gamma, sbar, Fstartlocation, Fperiods, n, q);

[forecast_record] = tv.forecast(data_endo_a, data_exo, beta_gibbs_forecast, sigma_gibbs_forecast, Fperiods, n, p, k, opt.const);


