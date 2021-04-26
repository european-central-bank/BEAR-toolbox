function [qj]=qrandj(n,Zj,stackedirfmat,Qj)


% first create the product Zj*f
% if there are no zero restriction on shock jj, Zjf is an empty matrix
if isempty(Zj)
Zjf=[];
% if there are zero restrictions on shock jj, generate the product Zj*f
else
Zjf=Zj*stackedirfmat;
end
% concatenate to obtain Rj
Rj=[Zjf;Qj'];

% now the procedure will differ according to whether Rj is empty or not obviously, one cannot find the nullspace of an empty matrix!
% if Rj is empty, no orthogonalisation is required
if isempty(Rj)
% simply draw a random vector from the standard normal
x=randn(n,1);
% normalise it to obtain column j of Q
qj=x/norm(x);
% if Rj is not empty (most common case), we have to go for the nullspace manipulation
% this will produce a vector orthogonal to the previous columns of the Q matrix and satisfying the 0 restrictions (if any)
else
% find a basis of the nullsapce of Rj
Nj_1=null(Rj);
% draw a random vector from the standard normal
x=randn(n,1);
% obtain column j of Q
qj=Nj_1*((Nj_1'*x)/norm(Nj_1'*x));

end






