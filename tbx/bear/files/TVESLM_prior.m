%implementation of the TVE SLM model by Martha Banbura and Andries van Vlodrop (2017) 
%by Ben Schumann (2020)

function [Ys, Yt, Y, data_endo, const, priorValues, dataValues, sizetraining]=...
    TVESLM_prior(data_endo, data_exo, names, endo, lags, lambda1, lambda2, lambda3, lambda5, ar, bex, dataSLM, namesSLM, datesSLM, const, priorexo, gamma)
%input n, data_endo, data_exo lags, q, lambda1, lambda2, lambda3, lambda5,ar bex,dataSLM, namesSLM, datesSLM, endo, names,n
%output ys, data_endo, Yt, const, priorValues,dataValues. data.values

%% Preliminaries
p=lags;
T = size(data_endo,1);
n = size(data_endo,2);
% compute m, the number of exogenous variables in the model
% if data_exo is empty, set m=0
if isempty(data_exo)==1
m=0;
% if data_exo is not empty, count the number of exogenous variables that will be included in the model
else
m=size(data_exo,2);
% Also, trim a number initial rows equal to the number of lags, as they will be suppressed from the endogenous as well to create initial conditions
data_exo=data_exo(p+1:end,:);
end

if const ==1
    m=m-1;
    const=0; %no constant as the VAR is estimated on the local mean adjusted variables
end 

% determine k, the number of parameters to estimate in each equation; it is equal to np+m
k=n*p+m;
% determine q, the total number of VAR parameters to estimate; it is equal to n*k
q=n*k;
%Divide the sample into a training sample and an estimation sample
sizetraining = floor(size(data_endo,1)/5) + lags;
Yt = data_endo(1:sizetraining,:);           %training sample
dataValues.Yt = Yt;                         %training sample

Y = data_endo((sizetraining-lags)+1:end,:); %estimation sample
dataValues.Y = Y;                           %estimation sample

dataValues.data_endo_full = data_endo;
data_endo = data_endo((sizetraining-lags)+1:end,:);

%Determine for which variables there is a survey local mean and build selection matrix

HaveSLM = ismember(endo,namesSLM)'; %first establish for which variables we have survey local mean data
ns = sum(HaveSLM);                  %check how many endogenous variables have a survey local mean
Ys = nan(size(Y,1),ns);
ni = 0;
Ppsi = zeros(ns,n);                 %create selection matrix for measurement equation
% for kk = 1:n
%     if HaveSLM(1,kk) ==1
%         ni = ni+1;
%         Ys(:,kk) = dataSLM(sizetraining-lags+1:end,kk);
%         Ppsi(ni,kk) = 1;            %selection matrix for local mean measurement equation
%     end
% end
for kk = 1:n
    if ismember(endo{kk,1},namesSLM)
        %find entry in ismember
        IndexC= find(strcmp(namesSLM, endo{kk,1}));
        ni = ni+1;
        Ys(:,IndexC) = dataSLM(sizetraining-lags+1:end,IndexC);
        Ppsi(IndexC,kk) = 1;            %selection matrix for local mean measurement equation
    end
end

dataValues.Ppsi = Ppsi;

dataValues.Ys = Ys;                 %Survey local mean after training sample

%%%%%%%%%%%%%%%%%% set the prior values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% prior for stochastic volatility in VAR residuals priors (H = A^-1'*Lambda_t*A^-1')
%estimate an ar(p) process for setting the prior variances
[arvar]=arloop(Yt,1,lags,n);
arvar = arvar*((size(Yt,1)-lags-lags-1)/(size(Yt,1)-lags-1)); %translate bear into Banbura et al (2017) estimate of ar(4) VCV

priorValues.priorVarAscaling_H =10;  %prior variance for the below diagonal elements of A (constant part of VCV
priorValues.priorMeanAscaling_H=0;   %prior mean for the below diagonal elements of A

priorValues.mean_ln_h0=log(arvar);    %prior mean of the initial condition for stochastic volatilty VAR residuals
priorValues.var_ln_h0 = 10*ones(n,1); %prior variance for the inital condition  for stochastic volatilty VAR residuals

priorValues.phi_h=0.01;               %centering parameter for the variance of the stochastic volatility process in the VAR residuals
priorValues.d_h=10;                   %scaling parameter for the variance of the stochastic volatility process in the VAR residuals

priorValues.offset_c = 0.001;         %constant for log transformation in order to avoid numerical problems of log close to 0


%% Priors for Reduced form VAR coefficients (independent normal wishart)
priorValues.vars  =arvar; 
%for bear sampling
priorValues.lambda1=lambda1;        % overall tightness
priorValues.lambda2=lambda2;        % cross variable shrinkage
priorValues.lambda3=lambda3;        % lag shrinkage
priorValues.lambda5=lambda5;        % block exogeneity shrinkage
priorValues.ar = ar;                % prior values for ar(1) coefficients of the variable

%for banbura et al sampling
priorValues.lambda=lambda1^2;       % only used for banbura large model sampling
priorValues.theta=lambda3;          % only used for banbura large model sampling

if size(ar,1) < n              % if no variable specific priors were given 
    artemp=zeros(n,1);
    for kk=1:n
        artemp(kk,1)=ar;
    end 
    ar = artemp;
end 

% start with beta0, defined in (1.3.4)
% it is a q*1 vector of zeros, save for the n coefficients of each variable on their own first lag 
beta0=zeros(q,1);

for ii=1:n
beta0((ii-1)*k+ii,1)=ar(ii,1);
end


% if a prior for the exogenous variables is selected put it in here:
for ii=1:n
    beta0(k*ii)=priorexo(ii,1);
end

% next compute omega0, the variance-covariance matrix of beta, defined in (1.3.8)
% set it first as a q*q matrix of zeros
omega0=zeros(q,q);

% set the variance on coefficients related to own lags, using (1.3.5)
for ii=1:n
   for jj=1:p
   omega0((ii-1)*k+(jj-1)*n+ii,(ii-1)*k+(jj-1)*n+ii)=(lambda1/jj^lambda3)^2;
   end
end


%  set variance for coefficients on cross lags, using (1.3.6)
for ii=1:n
   for jj=1:p
      for kk=1:n
      if kk==ii
      else
      omega0((ii-1)*k+(jj-1)*n+kk,(ii-1)*k+(jj-1)*n+kk)=(arvar(ii,1)/arvar(kk,1))*(((lambda1*lambda2)/(jj^lambda3))^2);
      end
      end
   end
end


% finally set the variance for exogenous variables, using (1.3.7)
for ii=1:n 
   for jj=1:m
   omega0(ii*k-m+jj,ii*k-m+jj)=arvar(ii,1)*((lambda1*lambda4)^2);
   end
end


% if block exogeneity has been selected, implement it, according to (1.7.4)
if bex==1
   for ii=1:n
      for jj=1:n
         if blockexo(ii,jj)==1
            for kk=1:p
            omega0((jj-1)*k+(kk-1)*n+ii,(jj-1)*k+(kk-1)*n+ii)=omega0((jj-1)*k+(kk-1)*n+ii,(jj-1)*k+(kk-1)*n+ii)*lambda5^2;
            end
         else
         end
      end
   end
% if block exogeneity has not been selected, don't do anything 
else
end

priorValues.beta0=beta0;        %prior for the reduced form VAR coefficients in vectorized form
priorValues.omega0=omega0;       %prior variance for reduced form VAR coefficients 

%% Priors for the measurement equation (G)

priorValues.mean_ln_g0=zeros(ns,1); %mean of the initial condition in the variance of measurement equation residuals
priorValues.var_ln_g0 = 10*ones(ns,1); %variance of the initial condition in the variance of measurement equation residuals

priorValues.phi_g=0.01;    %centering parameter for the variance of measurement equation residuals
priorValues.d_g=10;        %scaling parameter for the variance of the stochastic volatility process in the VAR residuals

%% Priors for the local mean equation
priorValues.meanTS=mean(Yt)';          %start values for mean corrected Kalman smoother simulation in order to draw from the local mean process
priorValues.kappa = 1000;              %variance of the initial state for the local mean

priorValues.gamma = gamma;             %value for ar coefficient in 

priorValues.mean_ln_v0=log(arvar);     %prior mean of the initial condition for stochastic volatilty in the state transition equation
priorValues.var_ln_v0 = 10*ones(n,1);  %prior variance of the initial condition for stochastic volatilty in the state transition equation

priorValues.d_v=10;                    %scaling parameter for the variance of the stochastic volatility process in the VAR residuals
priorValues.phi_v=0.01;                %centering parameter for the variance of transition equation residuals
