function [h, h0, hshock, kai2States] = ...
    StochVolKSCcorrsqrt(logy2, h, hVCVsqrt, Eh0, sqrtVh0, KSC, KSCt, Nsv, T)
% StochVolKSC performs a Gibbs updating step on a SV model and it works over 
% Nsv independent SV residuals
%
% Uses Kim, Shephard and Chib normal mixtures
%
% USAGE:[h, h0, kai2States] = StochVolKSCcorr(logy2, h, hVCV, Eh0, Vh0, KSC, KSCt, Nsv, T)
%
% multivariate case with correlated shocks and RW dynamics
%
% See also rwnoisePrecisionBasedSampler, getKSC7values, getKSC10values

%   Coded by  Elmar Mertens, em@elmarmertens.com

if isscalar(Eh0)
    Eh0 = repmat(Eh0, Nsv, 1);
end
if isscalar(sqrtVh0)
    sqrtVh0 = sqrtVh0 * speye(Nsv);
end
if isvector(sqrtVh0)
    sqrtVh0 = sparse(diag(sqrtVh0)); % better to define as speye in
                                     % callin function, this is just a backstop
elseif ~issparse(sqrtVh0)
    sqrtVh0 = sparse(sqrtVh0); % better to define as sparse in
                               % calling function, this is just a backstop
end


%% draw mixture states
% zdraws are standardized draws for each component of the normal mixture 
% zdraws is thus Nsv x T x Nmixtures
% zdraws      = bsxfun(@minus, logy2 - h, KSCt.mean) ./ KSCt.vol;
zdraws      = (logy2 - h - KSCt.mean) ./ KSCt.vol;

% construct CDF
% factor of sqrt(2 * pi) can be ommitted for kernel
pdfKernel           = KSCt.pdf ./ KSCt.vol .* exp(-.5 * zdraws.^2); 
cdf                 = cumsum(pdfKernel, 3);                % integrate
% cdf(:,:,1:end-1)    = bsxfun(@rdivide, cdf(:,:,1:end-1), cdf(:,:, end)); 
cdf(:,:,1:end-1)    = cdf(:,:,1:end-1) ./ cdf(:,:, end); % using automatic expansion 
cdf(:,:,end)        = 1;    % normalize

% draw states
% kai2States  = sum(bsxfun(@gt, rand(rndStream, Nsv, T), cdf), 3) + 1;
kai2States  = sum(rand(Nsv, T) > cdf, 3) + 1;


%% KSC State Space
obs         = logy2 - KSC.mean(kai2States);

% precision based sampler
vecobs           = obs(:);
noisevol         = KSC.vol(kai2States(:));
[h, hshock, h0]  = largeshockUtils.rwnoisePrecisionBasedSampler(vecobs, Nsv, T, hVCVsqrt, noisevol,...
    Eh0, sqrtVh0, 1);




