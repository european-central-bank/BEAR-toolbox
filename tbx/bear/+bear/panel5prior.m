function [d1 d2 d3 d4 d5 d Xi1 Xi2 Xi3 Xi4 Xi5 Xi Y y Xtilde Xdot theta0 Theta0]=panel5prior(N,n,p,m,k,q,h,T,Ymat,Xmat)

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

% now generate the Y, y, Xtilde and Xdot matrices
% initiate
Y=[];
y=[];
Xtilde=[];
Xdot=[];
% loop over sample periods
for ii=1:T
y=[y;Ymat(ii,:)'];
Y=[Y Ymat(ii,:)'];
Xbart=kron(speye(N*n),Xmat(ii,:));
Xtildt=Xbart*Xi;
Xtilde=[Xtilde Xtildt'];
Xdot=[Xdot Xtildt];
end

% finally, generate the theta0 and Theta0 elements
theta0=sparse(d,1);
Theta0=sparse(diag(10000*ones(d,1)));

