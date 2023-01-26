function [d1 d2 d3 d4 d5 d Xi1 Xi2 Xi3 Xi4 Xi5 Xi y Xtilde thetabar theta0 H Thetatilde Theta0 G]=panel6prior(N,n,p,m,k,q,h,T,Ymat,Xmat,rho,gama)














d1=1;
d2=N;
d3=n;
d4=p-1;
d5=m;
d=d1+d2+d3+d4+d5;

% Xi1 matrix (common component)
Xi1=sparse(ones(h,1));

% Xi2 matrix (unit component)
base=[repmat(kron(speye(N),sparse(ones(n,1))),p,1);sparse(m,N)];
Xi2=[];
for ii=1:N
Xi2=[Xi2 [sparse((ii-1)*q,1);repmat(base(:,ii),n,1);sparse((N-ii)*q,1)]];
end

% Xi3 matrix (variable component)
base=[repmat(speye(n),p*N,1);sparse(m,n)];
Xi3=[];
for ii=1:n
Xi3=[Xi3 repmat([sparse((ii-1)*k,1);base(:,ii);sparse((n-ii)*k,1)],N,1)];
end

% Xi4 matrix (lag component)
base=[kron(speye(p),sparse(ones(N*n,1)));sparse(m,p)];
Xi4=repmat(base(:,1:p-1),N*n,1);

% Xi5 matrix (exogenous component)
base=[sparse(k-m,m);speye(m)];
Xi5=repmat(base,N*n,1);

Xi=[Xi1 Xi2 Xi3 Xi4 Xi5];





% then obtain Theta0, the prior mean of the Teta vector
% this requires thetabar (the long run value) and theta0 (the initial or period-0 value)
% to obtain thetabar, obtain the OLS estimate of the static version of the factor model (XXX)
% and to obtain this OLS estimate, obtain first the regressors y and Xtilde
% initiate
y=[];
X=[];
Xtilde=[];
% loop over sample periods
for ii=1:T
y=[y;Ymat(ii,:)'];
Xbart=kron(speye(N*n),Xmat(ii,:));
Xtildt=Xbart*Xi;
X=[X;Xtildt];
Xtilde=blkdiag(Xtilde,Xtildt);
end
Xtilde=sparse(Xtilde);

% then obtain thetabar by OLS
thetabar=(X'*X)\(X'*y);

% set theta0 as the long-run value
theta0=thetabar;

% obtain H
H=speye(T*d)+sparse(-rho*diag(ones((T-1)*d,1),-d));

% obtain Thetatilde
Thetatilde=repmat((1-rho)*thetabar,T,1);
Thetatilde(1:d,1)=Thetatilde(1:d,1)+rho*theta0;
Thetatilde=sparse(Thetatilde);

% obtain Theta0
Theta0=H\Thetatilde;

% obtain G
G=speye(T)+sparse(-gama*diag(ones(T-1,1),-1));

