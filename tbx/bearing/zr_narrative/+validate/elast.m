function valid = elast(~, ident, ~, ir, ~)

valid = true;

for i = 1 : size(ident.elast, 1)

  varIndOf    = ident.elast(i, 1);
  varIndTo    = ident.elast(i, 2);
  shockInd    = ident.elast(i, 3);
  hor         = ident.elast(i, 4) + 1;
  bound       = ident.elast(i, 5);

  elast = ir(varIndOf, shockInd, hor) / ir(varIndTo, shockInd, hor);

  valid = elast < bound;

  if ~valid
    return
  end

end

end