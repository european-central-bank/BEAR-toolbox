function [yStarAdj, Ht] = statesMix(Ystar,h)
% This function takes a draw from the 7 mixture states.
%Ystar = yStar (forecast errors of the measurement equation)
%h=lnSigma2
%% Initialize 
T = length(h);
 
%% save normal mixture
pi = [0.0073 .10556 .00002 .04395 .34001 .24566 .2575];
mi = [-10.12999 -3.97281 -8.56686 2.77786 .61942 1.79518 -1.08819] - 1.2704;  %% means already adjusted!! %%
sigi = [5.79596 2.61369 5.17950 .16735 .64009 .34023 1.26261];
sqrtsigi = sqrt(sigi);

%% sample S from a 7-point discrete distribution
temprand = rand(T,1);
q = repmat(pi,T,1).*normpdf(repmat(Ystar,1,7),repmat(h,1,7)+repmat(mi,T,1), repmat(sqrtsigi,T,1));
q = q./repmat(sum(q,2),1,7);
S = 7 - sum(repmat(temprand,1,7)<cumsum(q,2),2)+1;

%adjust the residuals of the measurement equation using the estimated
%states and compute the state specific variance
vart = zeros(T,1);
yss1 = zeros(T,1);
for i = 1:T
    imix = S(i);   
    vart(i) = sigi(imix);
    yss1(i) = Ystar(i) - mi(imix);
end

%% save variances and mean adjusted yStar
Ht=vart;
yStarAdj=yss1;
 
end
