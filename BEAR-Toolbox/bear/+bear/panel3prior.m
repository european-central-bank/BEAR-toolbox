function [b bbar sigeps]=panel3prior(Xibar,Xbar,yi,y,N,q)









% first obtain b, the mean group estimator
% estimate the first term
term1=sparse(q,q);
for ii=1:N
term1=term1+Xibar{ii,1}'*Xibar{ii,1};
end

% estimate the second term
term2=sparse(q,1);
for ii=1:N
term2=term2+Xibar{ii,1}'*yi(:,:,ii);
end

% obtain b
b=term1\term2;

% obtain bbar
bbar=repmat(b,N,1);

% obtain sigma_epsilon, the common residual variance term
eps=y-Xbar*bbar;
sigeps=var(eps);

