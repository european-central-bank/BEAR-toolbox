function valid = irfSign(~, ident, ~, ir, ~)

valid = true;

if ~isempty(ident.irfSign.sign)
  indSign = ~isnan(ident.irfSign.sign);
  if any(indSign)
    valid = all(sign(ir(indSign)) == ident.irfSign.sign(indSign));
  end
end

end