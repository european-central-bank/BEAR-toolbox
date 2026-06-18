function y = gammainvcdf(u, shape, scale)

y = gammaincinv(u, shape) .* scale;

end