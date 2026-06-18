function cholSigma = randCholIWish(cholScale, df)

n = size(cholScale, 1);

Z = zeros(n);
for i = 1 : n
  for j = 1 : i-1
    Z(i, j) = randn();
  end
  Z(i, i) = sqrt(sum(randn(df-n+i, 1).^2));
end

opts.LT = true;
cholSigma = linsolve(Z, cholScale, opts);

end