function valid = narrContr(bvar, ident, ~, ir, shocks)

valid = true;

for i = 1 : size(ident.narrContr, 1)

  varInd      = ident.narrContr(i, 1);
  shockInd    = ident.narrContr(i, 2);
  initInd     = ident.narrContr(i, 3);
  dateInd     = ident.narrContr(i, 4);
  contrType   = ident.narrContr(i, 5);

  structShocksi = shocks(initInd : dateInd, :);

  irj = ir(:, :, 1 : dateInd-initInd+1);

  shockContr   = utils.calcContrib(irj, structShocksi, varInd);
  shockContr   = squeeze(shockContr(end, varInd, :));

  shockInd = (1 : bvar.nVars) == shockInd;

  switch contrType
    case -2
      valid = abs(shockContr(shockInd)) < sum(abs(shockContr(~shockInd)));
    case -1
      valid = abs(shockContr(shockInd)) == min(abs(shockContr));
    case 1
      valid = abs(shockContr(shockInd)) == max(abs(shockContr));
    case 2
      valid = abs(shockContr(shockInd)) > sum(abs(shockContr(~shockInd)));
  end

  if ~valid
    return
  end

end

end