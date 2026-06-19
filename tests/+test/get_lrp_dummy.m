function [Yl, Xl ]  = get_lrp_dummy(init_endo,H, n,m,order,lambda8)
    if rank(H)<size(H,1)
        error('Long run prior matrix H is co-linear, not able to invert')
    end
    H = sparse(H);
    invH = full(H\speye(n)); % invert H matrix
    ybar0 = mean(init_endo,1)';
    % generate Yl
    Yl=[];
    for ii=1:n
        temp=(H(ii,:)*ybar0/lambda8)*invH(:,ii);
        Yl=[Yl temp];
    end
    % generate Xl
    Xl=[repmat(Yl,1,order) zeros(n,m)];
end