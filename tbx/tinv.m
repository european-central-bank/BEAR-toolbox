function x = tinv(alpha,v)
    tdist2T = @(t,v) (1-betainc(v/(v+t^2),v/2,0.5));                                % 2-tailed t-distribution
    tdist1T = @(t,v) 1-(1-tdist2T(t,v))/2;                                          % 1-tailed t-distribution
    tmp = fzero(@(tval) (max(alpha,(1-alpha)) - tdist1T(tval,v)), 5);
    if alpha < (1-alpha)
        x = -tmp;
    else 
        x = tmp;
end

%max(alpha,(1-alpha))