function y = gammalpdf(x, shape, scale)

y = -gammaln(shape) - shape .* log(scale) + (shape - 1) .* log(x) - x./scale;

end