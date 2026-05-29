function out = logdet(x)
a=chol(x);
out=sum(log(diag(a))*2);

end

