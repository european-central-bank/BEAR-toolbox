function y = chi2rnd(df)

u = rand(size(df));
y = distr.chi2invcdf(u, df);

end