function [yt Xt Xbart]=stvoltmat(Y,X,n,T)




% recover yt
yt=reshape(Y',[n,1,T]);

% recover Xbart
Xt=cell(T,1);
Xbart=cell(T,1);
for ii=1:T
Xt{ii,1}=X(ii,:);
Xbart{ii,1}=kron(speye(n),X(ii,:));
end














