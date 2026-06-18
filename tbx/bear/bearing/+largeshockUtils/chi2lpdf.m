function y = chi2lpdf(x, df)

y = distr.gammalpdf(x, df/2, 2);

end