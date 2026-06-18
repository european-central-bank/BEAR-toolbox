function lpdf = betalpdf(x, alpha, beta)

if all(0 < x) && all(x < 1)
  lpdf = ...
    - betaln(alpha, beta) ...
    + (alpha-1) * log(x) + (beta-1) * log(1 - x);
else
  lpdf = -inf(size(x));
end

end