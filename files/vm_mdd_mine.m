%==========================================================================
%                 COMPUTE MARGINAL DATA DENSITY
%==========================================================================

function [mdd,YYact,YYdum,XXact,XXdum]=vm_mdd_mine(hyp,YY,spec,compute)
% compute = 1 stops the computation of the mdd, because we don't always need it


%==========================================================================
%                  Data Specification and Setting
%==========================================================================

nlags_  = spec(1);      % number of lags
T0      = spec(2);      % size of pre-sample
nex_    = spec(3);      % number of exogenous vars; 1 means intercept only
nv      = spec(4);      % number of variables
nobs    = spec(5);      % number of observations

%==========================================================================
%                         Dummy Observations
%==========================================================================


% Obtain mean and standard deviation from expandend pre-sample data

YY0     =   YY(1:T0+16,:);
ybar    =   mean(YY0)';
sbar    =   std(YY0)';
premom  =   [ybar sbar];

% Generate matrices with dummy observations

[YYdum, XXdum] = varprior(nv,nlags_,nex_,hyp,premom);

% Actual observations

YYact = YY(T0+1:T0+nobs,:);
XXact = zeros(nobs,nv*nlags_);
i = 1;

while (i <= nlags_)
    XXact(:,(i-1)*nv+1:i*nv) = YY(T0-(i-1):T0+nobs-i,:);
    i = i+1;
end

% last column of XXact = constant
XXact = [XXact ones(nobs,1)];

% dummy:  YYdum XXdum
% actual: YYact XXact

if compute == 1
    YY=[YYdum' YYact']';
    XX=[XXdum' XXact']';
    
    n_total = size(YY,1);
    n_dummy = n_total-nobs;
    nv     = size(YY,2);
    k      = size(XX,2);
    
    %==========================================================================
    %         Compute the log marginal data density for the VAR model
    %==========================================================================
    
%     Phi0   = (XXdum'*XXdum)\(XXdum'*YYdum);
    S0     = (YYdum'*YYdum)-((YYdum'*XXdum)/(XXdum'*XXdum))*XXdum'*YYdum;
    
%     Phi1   = (XX'*XX)\(XX'*YY);
    S1     = (YY'*YY)-((YY'*XX)/(XX'*XX))*XX'*YY;
    
    % compute constants for integrals
    
    i=1;
    gam0=0;
    gam1=0;
    
    while i <= nv;
        %gam0=gam0+log(gamma(0.5*(n_dummy-k+1-i)));
        gam0=gam0+gammaln(0.5*(n_dummy-k+1-i));
        %gam1=gam1+log(gamma(0.5*(n_total-k+1-i)));
        gam1=gam1+gammaln(0.5*(n_total-k+1-i));
        i=i+1;
    end;
    
    % dummy observation
    
    lnpY0 = -nv*(n_dummy-k)*0.5*log(pi)-(nv/2)*log(abs(det(XXdum'*XXdum)))...
        -(n_dummy-k)*0.5*log(abs(det(S0)))+nv*(nv-1)*0.25*log(pi)+gam0;
    
    % dummy and actual observations
    
    lnpY1 = -nv*(n_total-k)*0.5*log(pi)-(nv/2)*log(abs(det(XX'*XX)))...
        -(n_total-k)*0.5*log(abs(det(S1)))+nv*(nv-1)*0.25*log(pi)+gam1;
    
    lnpYY = lnpY1-lnpY0;
    
    % marginal data density
    mdd = lnpYY;
    
else
    mdd = NaN;
end