function [h, h0, hshock, SV, outlierlog2Draws, outlierProb, outlierScaleDraws] = ...
    StochVolOutlierKSCcorrsqrt(logy2, h, hVCVsqrt, Eh0, sqrtVh0, ...
    outlierlog2Draws, outlierProb, outlieralpha, outlierbeta, outlierStates, ...
    KSC, KSCt, Nsv, T)
% StochVolOutlierKSCcorrsqrt combines KSC Gibbs Sampling for SV with outlier model of Stock-Watson (2016, REStat)
%
% Uses Kim, Shephard and Chib normal mixtures
%
% USAGE : [h, h0, hshock, SV, outlierlog2Draws, outlierProb, outlierScaleDraws] = StochVolOutlierKSCcorrsqrt(logy2, h, hVCVsqrt, Eh0, sqrtVh0, outlierlog2Draws, ...
%         outlierProb, outlieralpha, outlierbeta, outlierStates, KSC, KSCt, ...
%         Nsv, T, rndStream)
%
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
% zdraws      = bsxfun(@minus, logy2 - h - outlierlog2Draws, KSCt.mean) ./ KSCt.vol;
zdraws      = (logy2 - h - outlierlog2Draws - KSCt.mean) ./ KSCt.vol;

% construct CDF
% factor of sqrt(2 * pi) can be ommitted for kernel
pdfKernel           = KSCt.pdf ./ KSCt.vol .* exp(-.5 * zdraws.^2); 
cdf                 = cumsum(pdfKernel, 3);                % integrate
% cdf(:,:,1:end-1)    = bsxfun(@rdivide, cdf(:,:,1:end-1), cdf(:,:, end)); 
cdf(:,:,1:end-1)    = cdf(:,:,1:end-1) ./ cdf(:,:, end); % using automatic expansion 
cdf(:,:,end)        = 1;    % normalize

% draw states
% kai2States  = sum(bsxfun(@gt, rand(Nsv, T), cdf), 3) + 1;
kai2States  = sum(rand(Nsv, T) > cdf, 3) + 1;


%% KSC State Space
obs         = logy2 - KSC.mean(kai2States) - outlierlog2Draws;

% precision based sampler
vecobs            = obs(:);
noisevol          = KSC.vol(kai2States(:));
[h, hshock, h0]   = largeshockUtils.rwnoisePrecisionBasedSampler(vecobs, Nsv, T, hVCVsqrt, noisevol, Eh0, sqrtVh0, 1);


%% outlier PDF
% outlierPdf is Nsurvey times T  times Nstates
% outlierPdf2 = cat(3, repmat(1 - outlierProb, 1, T), bsxfun(@times, outlierProb, repmat(1 / outlierNgrid, 1, T, outlierNgrid)));
outlierPdf  = cat(3, repmat(1 - outlierProb, 1, T), repmat(outlierProb / outlierStates.Ngrid, 1, T, outlierStates.Ngrid));

%% outlier states
edraws      = bsxfun(@minus, logy2 - h - KSC.mean(kai2States), permute(outlierStates.log2values, [1 3 2]));
zdraws      = bsxfun(@rdivide, edraws, KSC.vol(kai2States));

pdfKernel   = outlierPdf .* exp(-.5 * zdraws.^2);

cdf                 = cumsum(pdfKernel, 3);                % integrate
cdf(:,:,1:end-1)    = bsxfun(@rdivide, cdf(:,:,1:end-1), cdf(:,:,end)); 
cdf(:,:,end)        = 1;    % normalize


% draw states
ndx               = sum(bsxfun(@gt, rand(Nsv, T), cdf), 3) + 1;
outlierlog2Draws  = outlierStates.log2values(ndx);
outlierScaleDraws = outlierStates.values(ndx);

%% update outlierProb
Noutlier    = sum(ndx > 1, 2);
alpha       = outlieralpha + Noutlier;
beta        = outlierbeta + (T - Noutlier);

for n = 1 : Nsv

  outlierProb(n) = largeshockUtils.betadraw(alpha(n), beta(n), 1);

  % re matlab's betarnd:
  % - does not seem to support randomStreams (but compatible with parfor
  % according to documentation
  % - appears to be faster now (was different in earlier versions)

end

% outlierProb = betarnd(alpha, beta);

%% construct SV
SV = exp((h + outlierlog2Draws) / 2);
