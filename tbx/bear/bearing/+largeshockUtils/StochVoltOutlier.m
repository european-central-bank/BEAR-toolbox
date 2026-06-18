function [h, h0, hshock, SV, ...
    outlierlog2Draws, outlierProb, outlierScaleDraws, ...
    SVtScalelog2Draws, SVtdofDraws] = ...
    StochVoltOutlier(y2, logy2, h, hVCVsqrt, Eh0, sqrtVh0, ...
    outlierlog2Draws, outlierProb, outlieralpha, outlierbeta, outlierStates, ...
    tdof, ...
    KSC, KSCt, Nsv, T)
% 
%
% See also getKSC7values, getKSC10values, StochVolOutlierKSCcorrsqrt

%   Coded by  Elmar Mertens, em@elmarmertens.com


if isscalar(Eh0)
    Eh0 = repmat(Eh0, Nsv, 1);
end
if isscalar(sqrtVh0)
    sqrtVh0 = sqrtVh0 * eye(Nsv);
end

%% t-shocks via outlier draws (following JPR04)
y2scaled        = y2 .* exp(-h - outlierlog2Draws);
y2scaledGrid    = repmat(permute(y2scaled, [1 3 2]), [1 tdof.Ndof 1]);


dataloglike   = - .5 * (tdof.values + 1) .* sum(log(tdof.values + y2scaledGrid), 3); 
loglike       = tdof.loglike0 + dataloglike;

% check against stats pdf
% dofGrid = repmat(tdof.values, [Nsv, 1, T]);
% loglike2 = sum(log(tpdf(sqrt(y2scaledGrid), dofGrid)), 3);
% checkdiff(loglike, loglike2);

logposteriorKernel = tdof.logprior + loglike;
% note: adding prior could be dropped from kernel as long as the prior is uniform
% subtract const to avoid overflow
logposteriorKernelstar  = logposteriorKernel  - max(logposteriorKernel, [], 2);


cdf            = cumsum(exp(logposteriorKernelstar), 2);
cdf(:,1:end-1) = cdf(:,1:end-1) ./ cdf(:,end);
cdf(:,end)     = 1;
dofStates      = sum(rand( Nsv, 1) > cdf, 2) + 1;
SVtdofDraws    = tdof.values(dofStates)'; % transpose!


scalePosterior     = SVtdofDraws + 1 + y2scaled; % note the explicit vector expansion of SVtdof
% note: matlab doc says stats box handles parallel streams automatically via the global stream ....
% chi2draws          = chi2rnd(repmat(SVtdofDraws + 1, 1, T));

shape = repmat(SVtdofDraws + 1, 1, T) / 2;
scale = 2;
u = rand( size(shape));
chi2draws = gammaincinv(u, shape) .* scale;

SVtScalelog2Draws  = log(scalePosterior) - log(chi2draws);


%% draw mixture states
% zdraws are standardized draws for each component of the normal mixture 
% zdraws is thus Nsv x T x Nmixtures
% zdraws      = bsxfun(@minus, logy2 - h - outlierlog2Draws, KSCt.mean) ./ KSCt.vol;
zdraws      = (logy2 - h - outlierlog2Draws - SVtScalelog2Draws - KSCt.mean) ./ KSCt.vol;

% construct CDF
% factor of sqrt(2 * pi) can be ommitted for kernel
pdfKernel           = KSCt.pdf ./ KSCt.vol .* exp(-.5 * zdraws.^2); 
cdf                 = cumsum(pdfKernel, 3);                % integrate
% cdf(:,:,1:end-1)    = bsxfun(@rdivide, cdf(:,:,1:end-1), cdf(:,:, end)); 
cdf(:,:,1:end-1)    = cdf(:,:,1:end-1) ./ cdf(:,:, end); % using automatic expansion 
cdf(:,:,end)        = 1;    % normalize

% draw states
% kai2States  = sum(bsxfun(@gt, rand( Nsv, T), cdf), 3) + 1;
kai2States  = sum(rand( Nsv, T) > cdf, 3) + 1;

%% KSC State Space
obs   = logy2 - KSC.mean(kai2States) - outlierlog2Draws - SVtScalelog2Draws;
sqrtR = zeros(Nsv,Nsv,T);
for n = 1 : Nsv
    sqrtR(n,n,:) = KSC.vol(kai2States(n,:));
end

% note: for larger systems, smoothing sampler turns out to be more
% efficient than Carter-Kohn
[h, hshock, h0] = largeshockUtils.vectorRWsmoothingsampler1draw(obs, hVCVsqrt, sqrtR, Eh0, sqrtVh0);


%% outlier PDF
% outlierPdf is Nsurvey times T  times Nstates
% outlierPdf2 = cat(3, repmat(1 - outlierProb, 1, T), bsxfun(@times, outlierProb, repmat(1 / outlierNgrid, 1, T, outlierNgrid)));
outlierPdf  = cat(3, repmat(1 - outlierProb, 1, T), repmat(outlierProb / outlierStates.Ngrid, 1, T, outlierStates.Ngrid));

%% outlier states
edraws      = bsxfun(@minus, logy2 - h - SVtScalelog2Draws - KSC.mean(kai2States), permute(outlierStates.log2values, [1 3 2]));
zdraws      = bsxfun(@rdivide, edraws, KSC.vol(kai2States));

% pdfKernel   = exp(-.5 * zdraws.^2);  
% division by KSC.vol is unnecessary for this kernel, since same vol would apply across outlierStates

pdfKernel   = outlierPdf .* exp(-.5 * zdraws.^2);

cdf                 = cumsum(pdfKernel, 3);                % integrate
cdf(:,:,1:end-1)    = bsxfun(@rdivide, cdf(:,:,1:end-1), cdf(:,:,end)); 
cdf(:,:,end)        = 1;    % normalize


% draw states
ndx               = sum(bsxfun(@gt, rand( Nsv, T), cdf), 3) + 1;
outlierlog2Draws  = outlierStates.log2values(ndx);
outlierScaleDraws = outlierStates.values(ndx);

%% update outlierProb
Noutlier    = sum(ndx > 1, 2);
alpha       = outlieralpha + Noutlier;
beta        = outlierbeta + (T - Noutlier);

% outlierProb = betarnd(alpha, beta);

for n = 1 : Nsv
    outlierProb(n) = largeshockUtils.betadraw(alpha(n), beta(n), 1);
    % re matlab's betarnd:
    % - does not seem to support randomStreams
    % - seems to be slower
    % - call would be this: outlierProb(n) = betarnd(alpha(n), beta(n), 1);
end

%% construct SV
SV = exp((h + outlierlog2Draws + SVtScalelog2Draws) / 2);

