function y = igaminvcdf(u, shape, scale)

y = scale ./ gammaincinv(u, shape, "upper");

end