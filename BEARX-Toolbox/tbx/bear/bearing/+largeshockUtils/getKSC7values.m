function [KSC, KSCt, logy2offset] = getKSC7values(T, Nsv)
% GETKSC7VALUES returns coefficients from Kim, Shephard and Chib's normal-mixture approximation of a chi2 variable
%
% USAGE: [KSC, KSCt, logy2offset] = getKSC7values(T, Nsv) returns in addition, the structure KSCt, with the same fieldnames as KSC
%
% where KSC returns a structure with elements mean, vol, var, pdf, and cdf
% KSCt returns are corresponding structure but with fields "blown up" to dimension T x Nsv x 7 
% and logy2offset is the offset c used to compute log(y^2 + c)
%

%   Coded by  Elmar Mertens, em@elmarmertens.com


if nargin < 2
    Nsv = 1;
end

KSC.mean    = - 1.2704 + [-10.12999 -3.97281 -8.56686 2.77786 .61942 1.79518 -1.08819];
KSC.var     = [5.79596 2.61369 5.1795 .16735 .64009 .34023 1.26261];
KSC.vol     = sqrt(KSC.var);
KSC.pdf     = [.0073 .10556 .00002 .04395 .34001 .24566 .25750];
KSC.cdf     = cumsum(KSC.pdf);

% blowup to cover time dimension
if nargout > 1
    fn = fieldnames(KSC);
    for f = 1 : length(fn)
        KSCt.(fn{f}) = repmat(permute(KSC.(fn{f}), [1 3 2]), [Nsv, T, 1]);
    end
end

logy2offset = 0.001; 
