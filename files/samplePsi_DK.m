function PsiDraw = samplePsi_DK(YData,YsData,B,H,V,G,CD,meanTS,kappa,dataValues,KFSmatrices)
% This function takes a draw from the conditional posterior distribution of
% Psi (local mean).
% B=Bdraw;
% H=Hdraw;
% V=Vdraw;
% G=Gdraw;
% CD=CDdraw;
% kappa=priorValues.kappa
%% Initialize
yData=YData;
zData=YsData;
 
[T,n] = size(yData);
Mz = size(zData,2); %number of survey forecasts
p=size(B,1)/n;     %lags
na=n*(p+1);        %number of variables in state space

%% Matrices of state space representation
Zmatrix=KFSmatrices.Zmatrix; %(matrix for measurement equation)
Tmatrix=KFSmatrices.Tmatrix; %(matrix for state equation)
Tmatrix(n+1:2*n,n+1:end) = B'; %put the VAR coefficients in 
Rmatrix=KFSmatrices.R;        %scaling in front of errors for transition equation
Lmatrix=KFSmatrices.L;        %scaling in front of errors for measurement equation

%% Data vector and KF initialisation
ZYcol = [zData';yData']; %concatenate surveydata and var data

psiInit    = mean(ZYcol(Mz+1:end,1:p),2); %rowwhise mean
y_PsiStart = reshape(ZYcol(Mz+1:end,p:-1:1),n*p,1)-repmat(psiInit,p,1); %initial values in deviation from mean
aStart=[meanTS;  y_PsiStart]; %start values for transition equation (RHS) with mean followed by lags of yt in deviation from mean

Pstart=kappa*eye(na); %variance for the initial state

aplus = nan(na,T-p); %matrix storing all the period specific for transition equation
QQ = nan(na,na,T-p);
LL = nan(Mz+n,Mz+n,T-p);
yplus = nan(n+Mz,T-p);
aplus(:,1) = aStart+mvnrnd(zeros(na,1),Pstart,1)'; %initialiye RHS of transition equation equation
yplus(:,1) = Zmatrix*aplus(:,1)+[sqrt(G(p+1,:)').*randn(Mz,1);zeros(n,1)]; %initialize the RHS of measurement equation  
QQ(:,:,1) = Rmatrix*blkdiag(diag(V(p+1,:)),H(:,:,p+1))*Rmatrix'; %initial VCV of transition equation
LL(:,:,1) = Lmatrix*diag(G(p+1,:))*Lmatrix';                     %initial VCV of measurement equation 

%recursively simulate the matrices by drawing from multivariate normal
%using time period specific VCV where 
%H is the VCV of the VAR residuals, 
%V is the VCV of the state transition residuals and 
%G is the VCV of the measurement equation for the survey data

%mean correction simulation smoother
for t = 2:T-p
    %simulate the aplus matrix (constant in state transition equation) by drawing from the period specific distribution of the transition equation and VAR residuals 
    aplus(:,t) =  Tmatrix*aplus(:,t-1)+ [sqrt(V(t+p,:)').*randn(n,1);  mvnrnd(zeros(n,1),H(:,:,t+p),1)';zeros(na-2*n,1)];
    %simulate the yplus matrix (containing survey data and var data) by drawing from the period specific
    %distribution of the residuals from the measurement equation
    yplus(:,t) = Zmatrix*aplus(:,t)+[sqrt(G(t+p,:)').*randn(Mz,1);zeros(n,1)];
    %period specific VCV of transition equation
    QQ(:,:,t) = Rmatrix*blkdiag(diag(V(t+p,:)),H(:,:,t+p))*Rmatrix';
   %period specific VCV of measurement equation
    LL(:,:,t) = Lmatrix*diag(G(t+p,:))*Lmatrix';
end

ystar = ZYcol(:,p+1:T)-yplus; %
ahatstar = runKF_DK(ystar, Tmatrix, Zmatrix, QQ, LL, zeros(na,1), Pstart);
atilda = ahatstar+aplus;
PsiDraw = [nan(p,n);atilda(1:n,:)'];

end
 
