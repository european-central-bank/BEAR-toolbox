function[Bbar,St,aux1,vt,Sbar]=nwprior_for_IV(arvar,lambda1,lambda3,lambda4,m,p,k,q,X,Y,T,sigmahat,betahat,n)
%%%%Implementation of the normal wishart prior as described in Uhlig 2005
%translation into Uhligs Notation
%B0 = B0bar 
%Bbar = Bbar_T
B=reshape(betahat,k,n);
% start with beta0
beta0=zeros(q,1);
for ii=1:n
beta0((ii-1)*k+ii,1)=1;
end

v0=n+2;
% unvectorize (reshape) the vector to obtain the matrix B0bar
B0=reshape(beta0,k,n);

% set first phi0 as a k*k matrix of zeros
invN0=zeros(k,k);

% set the variance for coefficients on lagged values, using (1.4.5)
for ii=1:n
   for jj=1:p
   invN0((jj-1)*n+ii,(jj-1)*n+ii)=(1/arvar(ii,1))*(lambda1/jj^lambda3)^2;
   end
end

% set the variance for exogenous variables, using (1.4.6) 
%%%%and constant? what if we dont have exogenous variables
for ii=1:m
invN0(k-m+ii,k-m+ii)=(lambda1*lambda4(ii))^2; %invN0(k-m+ii,k-m+ii)=(lambda1*lambda4)^2;
end

S0=(v0-n-1)*diag(arvar);
%S0=0;
% compute the inverse of phi0
% as it is a diagonal matrix, simply to take the inverse of each diagonal element
N0=diag(1./diag(invN0));

% compute Nt, defined in (1.4.16)
Nt=N0+X'*X;

C=trns(chol(nspd(Nt),'Lower'));
invC=C\speye(k);
aux1=invC*invC';

% compute Bbar, defined in (1.4.17)
Bbar=aux1*(N0*B0+X'*Y);% compute Nt, defined in (1.4.16)

%vectorize
betabar=Bbar(:);


%degrees of freedom
vt=T+v0;

%calculate St as in Uhlig 2005
St = v0/vt*S0+T/vt*sigmahat+1/vt*((B-Bbar)')*N0*inv(Nt)*(X'*X)*(B-Bbar);

Sbar=Y'*Y+S0+B0'*N0*B0-Bbar'*Nt*Bbar;

% stabilise Sbar to avoid numerical errors
St=nspd(St);

end