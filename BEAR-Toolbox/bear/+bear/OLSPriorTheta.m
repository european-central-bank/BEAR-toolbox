function [coeff,variance]=OLSPriorTheta(y,timetrend,f)
% OLSPriorTheta(y,timetrend,f) computes the prior for coefficients of the
% deterministic trends in the TVE-VAR approach. The prior is normally
% distributed with mean "coeff" and variance "variance". The prior
% parameters are computed regressing the data y on timetrend. Then, coeff is
% the OLS estimate, and variance is the asymptotic variance of the OLS,
% scaled up of a factor f.


%% Prepare data: make sure the dimensions of the inputs are correct
if size(y,1)>size(y,2)
    y=y';
end
if size(timetrend,1)>size(timetrend,2)
    timetrend=timetrend';
end

%% Run OLS
T=size(y,2); % number of data available
k=size(timetrend,1); % number of regressors

P=y*timetrend'*inv(timetrend*timetrend'); % the OLS coefficients
resid=y-P*timetrend; % the residuals from the regression
O=1/(T-k)*resid*resid';
Q=timetrend*timetrend';
varpar=kron(O,Q^-1); % the asymptotic variance

%% The output
variance=varpar*f;
coeff=P';

end