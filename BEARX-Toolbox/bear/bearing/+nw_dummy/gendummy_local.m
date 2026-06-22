function [Ystar, ystar, Xstar, Tstar, Ydum, ydum, Xdum, Tdum]=gendummy_local(data_endo,data_exo,Y,X,n,m,p,T,const,...
    lambda1,lambda3, lambda4,lambda6,lambda7,lambda8,scoeff,iobs,lrp,mindum,H, ar, arvar, priorexo)
%GENDUMMY

% if the sum-of-coefficients option was selected,generate Ys, Xs and Ts, defined in (XXX) and (XXX)
if scoeff==1
    Ys=diag(mean(data_endo(1:p,:),1)/lambda6);
    Xs=[kron(ones(1,p),Ys) zeros(n,m)];
    Ts=n;
else
    Ys=[];
    Xs=[];
    Ts=0;
end


% if the initial observation option was selected, generate Yo, Xo and To, defined in (XXX) and (XXX)
if iobs==1
    Yo=mean(data_endo(1:p,:),1)/lambda7;
    % if a constant term has been included into the model, augment the matrix of exogenous with a column of ones
    if const==1
        dataexo=[ones(size(data_endo,1),1) data_exo];
    elseif const==0
        dataexo=[];
    end
    % check for the existence of exogenous variables, and generate xbar
    if isempty(dataexo)
        xbar=[];
    else
        xbar=mean(dataexo(1:p,:));
    end
    % finally, generate Xo
    Xo=[kron(ones(1,p),Yo) xbar/lambda7];
    To=1;
else
    Yo=[];
    Xo=[];
    To=0;
end

% Long run priors
% if long run prior was selected, generate Yl, Xl and Tl
if lrp==1
    if rank(H)<size(H,1)
        error('Long run prior matrix H is co-linear, not able to invert')
    end
    H=sparse(H);
    invH=full(H\speye(n)); % invert H matrix
    ybar0=mean(data_endo(1:p,:),1);
    % generate Yl
    Yl=[];
    for ii=1:n
        temp=(H(ii,:)*ybar0'/lambda8)*invH(:,ii);
        Yl=[Yl temp];
    end
    % generate Xl
    Xl=[repmat(Yl,1,p) zeros(n,m)];
    Tl=1;
else
    Yl=[];
    Xl=[];
    Tl=0;
end


if mindum
   Yd=[diag(ar(1:n,1).*arvar/lambda1);zeros(n*(p-1),n);(priorexo./(lambda1.*lambda4))';diag(arvar)];
   % generate Xd, using (XXX)
   Jp=diag([1:p].^lambda3);
   Xd=[kron(Jp,diag(arvar/lambda1)) zeros(n*p,m);zeros(m,n*p) diag(1./(lambda1*lambda4(1,:)));zeros(n,n*p) zeros(n,m)]; % error if m is equal to zero
   % Compute Td, using (XXX)
   Td=n*(p+1)+m;
else
   Yd=[];
   Xd=[];
   Td=0;
end


% generate the dummy data set
Ydum=[Ys;Yo;Yl;Yd];
ydum=Ydum(:);
Xdum=[Xs;Xo;Xl;Xd];
Tdum=0+Ts+To+Tl+Td;

% generate the total data set by concatenating the dummies
Ystar=[Y;Ydum];
ystar=Ystar(:);
Xstar=[X;Xdum];
Tstar=T+Tdum;