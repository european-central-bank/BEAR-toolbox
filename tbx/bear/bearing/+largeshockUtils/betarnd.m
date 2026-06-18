function y = betarnd(alpha, beta)

u = rand(size(alpha));
y = distr.betainvcdf(u, alpha, beta);

end