function y = igamcdf(x, shape, scale)

y = gammainc(scale ./ x, shape, "upper");

end