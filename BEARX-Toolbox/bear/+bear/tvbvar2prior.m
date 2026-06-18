function [chi psi kappa S H I_tau G I_om f0 upsilon0]=tvbvar2prior(arvar,n,q,T,gamma)



% set the value of chi at 1000 (this is to avoid implausible or explosive behaviour)
chi=200;

% set the value of Q as a fraction of the OLS estimate, times degrees of freedom (see Chan and Jeliazkov or Primiceri)
psi=0.001;

% set the value of kappa at n+1 (minimum df at which the distribution is defined)
kappa=n+3;

% set S as the scale for the standard inverse Whishart prior
%S=(kappa-n-1)*diag(arvar);
S=eye(n);

% Generate H
H=sparse(kron(diag(-ones(T-1,1),-1)+eye(T),eye(q)));
% generate I_tau
% set tau as large value
tau=10000;
% then generate I_phi
I_tau=sparse(diag([1/tau;ones(T-1,1)]));
% compute the G matrix
G=speye(T)-sparse(diag(gamma*ones(T-1,1),-1));
% generate I_om
% set omega as large value
om=5;
% then generate I_phi
I_om=sparse(diag([1/om;ones(T-1,1)]));


% compute the series of f0 vector and upsilon0 matrices
f0=cell(n,1);
upsilon0=cell(n,1);
for ii=2:n
f0{ii,1}=zeros(ii-1,1);
upsilon0{ii,1}=10000*eye(ii-1);
end







