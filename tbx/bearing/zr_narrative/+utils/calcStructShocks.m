function shocks = calcStructShocks(B, S, Y, X)

[T, nShocks] = size(Y);
N = size(B, 3);

shocks = nan(T, nShocks, N);

for i = 1 : N

  Bi = B(:, :, i);
  Si = S(:, :, i);

  resid = Y - X * Bi;
  shocks(:, :, i)  = resid / Si';
  
end

end