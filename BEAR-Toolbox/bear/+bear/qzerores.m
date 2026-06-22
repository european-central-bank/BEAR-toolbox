function [Q]=qzerores(n,Zcell,stackedirfmat)

% function [Q]=qzerores(n,Zcell,stackedirfmat)
% computes an orthogonal matrix Q which satisfies the zero restrictions
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'Zcell': cell containing the Z matrices for the zero restrictions
% outputs: - matrix 'Q': orthogonal matrix satisfying the zero restrictions
% initiate Qj
Qj=[];
% loop over j values, j=1,2,...,n
for jj=1:n
% create Rj
% first create the product Zj*f
   % if there are no zero restriction on shock jj...
   if isempty(Zcell{1,jj})
   Zjf=[];
   else
   Zjf=Zcell{1,jj}*stackedirfmat;
   end
Rj=[Zjf;Qj'];

% now the procedure will differ according to whether Rj is empty or not
% obviously, one cannot find the nullspace of an empty matrix!
   % if Rj is empty, no orthogonalisation is required
   if isempty(Rj)
   % simply draw a random vector form the standard normal
   x=normrnd(0,1,n,1);
   % normalise it
   x=x/norm(x);
   % increment Qj
   Qj=[Qj x];
   % if Rj is not empty (most common case), we have to go for the nullspace manipulation
   else
   % find a basis of the nullsapce of Rj
   Nj_1=null(Rj);
   % draw a random vector form the standard normal
   x=normrnd(0,1,n,1);
   % and obtain the Q column satisfying the zero restriction
   x=Nj_1*((Nj_1'*x)/norm(Nj_1'*x));
   % increment Qj
   Qj=[Qj x];
   end
end

% set Q=Qj
Q=Qj;



