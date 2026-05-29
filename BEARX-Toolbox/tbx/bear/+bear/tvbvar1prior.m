function [chi psi kappa S H I_tau]=tvbvar1prior(arvar,n,q,T)



% set the value of chi at 1000 (this is to avoid implausible or explosive behaviour)
chi=200;

% set the value of psi at 0.01
psi=0.01;

% set the value of kappa at n+1 (minimum df at which the distribution is defined)
kappa=n+2;

% set S as the scale for the standard inverse Whishart prior
S=(kappa-n-1)*diag(arvar);

% Generate H
%H=sparse(kron(diag(-ones(T-1,1),-1)+eye(T),eye(q)));	% this is not memory efficient
H = kron(spdiags([-ones(T,1),ones(T,1)],-1:0,T,T),speye(q));

% generate I_tau
% set tau as large value
tau=10000;
% then generate I_phi
%I_tau=sparse(diag([1/tau;ones(T-1,1)]));	% this is not memory efficient
I_tau = spdiags([1/tau;ones(T-1,1)],0,T,T);
