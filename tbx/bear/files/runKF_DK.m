function xFS = runKF_DK(y, A, C, Q, R, x_0, Sig_0,c1,c2)
% %(ystar, Tmatrix, Zmatrix, QQ, LL, zeros(Ma,1), Pstart)
% y=ystar; %(y in deviation from time varying mean)
% A=Tmatrix; %(transition equation matrix)
% C=Zmatrix; %(measurement equation matrix)
% Q=QQ; %(%period specific VCV of transition equation)
% R=LL; %(period specific VCV of measurement equation)
% x_0=zeros(Ma,1); %mean of normal for initial state
% Sig_0 = Pstart; %variance for the initial stateVCV of normal for initial state
% c1 = zeros(size(y,1),1);
% c2 = zeros(size(A,1),1); 
if nargin<9
    c2 = zeros(size(A,1),1);
    if nargin<8
    c1 = zeros(size(y,1),1);
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Runs Kalman filter and smoother

% run the filter
S = SKF(y,C,R,A,Q, x_0, Sig_0,c1,c2);
% run the smoother
S = FIS(y,C,R,A,Q,S); 

xFS = S.AmT;



 


