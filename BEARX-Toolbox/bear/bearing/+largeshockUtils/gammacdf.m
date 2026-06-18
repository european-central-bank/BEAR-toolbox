function y = gammacdf(x, shape, scale)

y = gammainc(x ./ scale, shape);

end