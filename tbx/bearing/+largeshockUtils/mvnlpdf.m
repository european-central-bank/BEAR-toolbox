function lpdf = mvnlpdf(x, cholSigma)

[T, n] = size(x);

lpdf = -n/2*log(2*pi) - sum(log(diag(cholSigma)));
lpdf = repmat(lpdf, T, 1);

opts.LT = true;
xPinv = linsolve(cholSigma, x', opts)';

for t = 1 : T
  lpdf(t) = lpdf(t) - 0.5 * xPinv(t, :) * xPinv(t, :)';
end

end