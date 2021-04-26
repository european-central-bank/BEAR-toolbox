function [yt y Xt Xbart Xbar]=tvbvarmat(Y,X,n,q,T)




% recover yt
yt=reshape(Y',[n,1,T]);

% recover y
y=vec(Y');

% initiate Xbar
Xbar=cell(T,T);
for ii=1:T
    for jj=1:T
    Xbar{ii,jj}=sparse(n,q);
    end
end

% recover Xbart and Xbar
Xt=cell(T,1);
Xbart=cell(T,1);
for ii=1:T
Xt{ii,1}=X(ii,:);
Xbart{ii,1}=kron(speye(n),X(ii,:));
Xbar{ii,ii}=Xbart{ii,1};
end

% turn cell Xbar into matrix Xbar
Xbar=cell2mat(Xbar);













