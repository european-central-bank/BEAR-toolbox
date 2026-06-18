function y = multgammaln(a, p)

    y = p*(p-1)/4 * log(pi) + sum(gammaln(a - (0:p-1)/2));

end