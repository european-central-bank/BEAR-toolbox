function y = gammarnd(shape, scale)

u = rand(size(shape));
y = distr.gammainvcdf(u, shape, scale);

end