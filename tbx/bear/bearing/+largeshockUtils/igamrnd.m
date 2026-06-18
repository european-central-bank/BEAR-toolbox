function y = igamrnd(shape, scale)

u = rand(size(shape));
y = distr.igaminvcdf(u, shape, scale);

end