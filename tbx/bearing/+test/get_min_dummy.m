function [Ym,Xm]=get_min_dummy(n,m,order,ar,arvar,lambda1,lambda3,lambda4,priorexo)

Ym=[diag(ar(1:n,1).*arvar/lambda1);zeros(n*(order-1),n);(priorexo./(lambda1.*lambda4))';diag(arvar)];

Jp=diag([1:order].^lambda3);
Xm=[kron(Jp,diag(arvar/lambda1)) zeros(n*order,m); ...
    zeros(m,n*order) diag(1./(lambda1*lambda4(1,:)));...
    zeros(n,n*order) zeros(n,m)]; % error if m is equal to zero
end


