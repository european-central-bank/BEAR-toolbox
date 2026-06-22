function s = iwstd(scale, df)

n = size(scale, 1);

tmp1 = scale.^2;
tmp2 = diag(scale) .* diag(scale)';

s = ((df - n + 1) * tmp1 + (df - n - 1) * tmp2) / ((df - n) * (df - n - 1)^2 * (df - n - 3));

end