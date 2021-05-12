function [phiDraw]=samplePhi(logSVseries,priorD,priorPhi)
% This function takes a draw from the conditional posterior distribution of
% phi in the SV equation.
%logSVseries=log(Hvars(p+1:end,kk));
%priorD =priorD_H;
%priorPhi = priorPhi_H;
%% Initialize
T=length(logSVseries);
vDiffSV=logSVseries(2:T)-logSVseries(1:T-1);

%% posteror parameter values
a1=priorD*priorPhi+sum(vDiffSV.^2);
b1=priorD+(T-1);

%% Take a draw form the posterior distribution
%gammaDraw=gamrnd(a1/2,2/b1);
%gammaDraw=grandn(a1/2,2/b1);
gammaDraw=grandn(b1/2,2/a1);
phiDraw=1/gammaDraw;
   
end

