function valid = narrSign(~, ident, ~, ~, shocks)

valid = true;

if ~isempty(ident.narrSign)
  indNarrSign  = ~isnan(ident.narrSign);
  if any(indNarrSign)
    valid = all(sign(shocks(indNarrSign)) == ident.narrSign(indNarrSign));
  end
end

end