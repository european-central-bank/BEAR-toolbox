function y = chi2invcdf(u, df)

y = distr.gammainvcdf(u, df/2, 2);

end