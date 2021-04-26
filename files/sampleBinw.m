function [Bdraw,stationary]=sampleBinw(yData,PsiDraw_prop,Hdraw_prop,p,priorValues, q, k)

omega0 = priorValues.omega0;
beta0 = priorValues.beta0;

Y_Psi=yData-PsiDraw_prop;
Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*mean(yData(1:p,:));
%X_Psi = lagmatrix(Y_Psi,1:p);
%X_Psi = X_Psi(p+1:end,:);
%Y_Psi=Y_Psi(p+1:end,:);

X_Psi = lagx(Y_Psi,p-1);
X_Psi = X_Psi(1:end-1,:);
% X_Psi = X_Psi(p+1:end,:);     %remove the first p rows of RHS
Y_Psi=Y_Psi(p+1:end,:);       %and do so for LHS

[T,n] = size(Y_Psi);
%construct the required matrices for periodwise summation
[yt, ~, Xbart]=stvoltmat(Y_Psi,X_Psi,n,T);

%draw beta from its conditional posterior
% first compute the summations required for omegabar and betabar
summ1=zeros(q,q);
summ2=zeros(q,1);
Hdraw_cut = Hdraw_prop(:,:,p+1:end);
   % run the summation
   for jj=1:T
   prodt=Xbart{jj,1}'/Hdraw_cut(:,:,jj);
   summ1=summ1+prodt*Xbart{jj,1};
   summ2=summ2+prodt*yt(:,:,jj);
   end
% then obtain the inverse of omega0
invomega0=diag(1./diag(omega0));
% obtain the inverse of omegabar
invomegabar=summ1+invomega0;
% recover omegabar
C=chol(nspd(invomegabar),'Lower')';
invC=C\speye(q);
omegabar=invC*invC';
% recover betabar
betabar=omegabar*(summ2+invomega0*beta0);
% finally, draw beta from its posterior
beta=betabar+chol(nspd(omegabar),'lower')*randn(q,1);

Bdraw = reshape(beta,k,n);

[stationary,~]=checkstable(beta,n,p,k);

