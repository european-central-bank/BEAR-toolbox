function lpdf = paretolpdf(x, scale, shape)

arguments
  x       (:,1)
  scale   (:,1)
  shape   (:,1)
end

if scale <= x
  lpdf = ...
    + log(shape) + shape .* log(scale) ...
    - (shape + 1) .* log(x);
else
  lpdf = -inf;
end

end