function sf = scaleFactor(theta, T, T0)

    n   = numel(theta);
    T1  = T0 + n - 2;
    
    sf            = ones(T, 1);
    sf(T0 : T1)   = theta(1 : n-1);
    sf(T1 + 1 : T)  = 1 + (sf(T1) - 1) * theta(n).^(1 : T - T1);

end