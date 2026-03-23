function ir = calcIRF(B, S, hor)

nVars = size(B, 2);
N     = size(B, 3);

ir = nan(nVars, nVars, hor+1, N);

for i = 1 : N

  Si  = S(:, :, i);
  ir(:, :, 1, i) = Si;

  if 0 < hor

    Bi  = B(:, :, i);
    Phii  = utils.companion(Bi);

    Phiih = Phii;
    for h = 1 : hor
      ir(:, :, h+1, i) = Phiih(1:nVars, 1:nVars) * Si;
      Phiih = Phiih * Phii;
    end

  end

end

end