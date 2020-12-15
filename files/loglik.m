function [out, problem]=loglik(beta,sigma,y,x)

% This function returns  the log-likelihood for the linear VAR model 
v=y-x*beta;
sterm=0;
isigma=invpd(sigma);
% Check if chol(isigma) exists 
problem=0;
try
  check= chol(isigma);
catch
 problem=1;
end


 if  ~problem
     
dsigma=logdet(isigma);% logdet returns the log of the determinant of a matrix
T=size(y,1);
N=size(y,2);
for i=1:T
    sterm=sterm+(v(i,:)*isigma*v(i,:)');
end


out=(-(T*N)/2)*log(2*pi)+(T/2)*dsigma-0.5*sterm;
 else
     out=nan;

 end
end

%out=(T/2)*dsigma-0.5*sterm;