function [Ys, Xs ]  = get_scoeff_dummy(init_endo, n,m,order,lambda6)
    Ys=diag(mean(init_endo,1)/lambda6);
    Xs=[kron(ones(1,order),Ys) zeros(n,m)];
end