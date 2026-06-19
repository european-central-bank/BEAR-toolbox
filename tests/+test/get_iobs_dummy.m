function [Yo, Xo ]  = get_iobs_dummy(init_endo,init_exo,order,lambda7)
    Yo = mean(init_endo,1)/lambda7;
    xbar = mean(init_exo,"omitnan");
    Xo = [kron(ones(1,order),Yo) xbar/lambda7];
end