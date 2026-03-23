function contr = calcContrib(ir, shocks, varInd, shockInd)

arguments
  ir
  shocks
  varInd    (1, :)  = 1 : size(ir, 1)
  shockInd  (1, :)  = 1 : size(ir, 2)
end

[T, nShocks] = size(shocks);

contr = zeros(T, nShocks, nShocks);

for i = varInd
  for j = shockInd
    for t = 1 : T
      for h = 1 : t
        contr(t, i, j) = contr(t, i, j) + ir(i, j, t-h+1) * shocks(h, j);
      end
    end
  end
end

end