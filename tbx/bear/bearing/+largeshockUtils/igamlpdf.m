function y = igamlpdf(x, shape, scale)

y = shape .* log(scale) - gammaln(shape) - (shape+1) .* log(x) - scale ./ x;

end