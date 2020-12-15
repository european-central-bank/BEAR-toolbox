function [aSim]=KF_CKsimSV(yStar,H,phi,a1,P1)
%% Purpose
%  This function runs the Kalman Filter and Backward Simulation recursions
%  from the Carter Kohn algorithm.#
% a1 = startMean
% P1 = startVar
%% Output
%  - aSim - 
%
%% Initialize
T=length(yStar);
 
aPrediction=zeros(T,1);
P_Prediction=zeros(T,1);

aUpdate=zeros(T,1);
P_Update=zeros(T,1);


%% Kalman Filter Recursion

% start round
aPrediction(1)=a1;
P_Prediction(1)=P1;

% mid-rounds
for t=2:T    
    vt=yStar(t-1)-aPrediction(t-1); %forecast error of measurement equation
    
    Ft=P_Prediction(t-1)+H(t-1); %conditional variance of vt|Yt-1 using the fact that Z is identity (random walk)
                                 %and the state dependend variance of the residuals from the auxilary mixture sampler
    Finv=1/Ft; %inverse of Ft again using the fact that Z is identity
    Kt=P_Prediction(t-1)*Finv; %Kalman Gain

    aUpdate(t-1)=aPrediction(t-1)+Kt*vt; % since Tt=identity
    P_Update(t-1)=P_Prediction(t-1)*(1-Kt);  %Pt|t, variance of the state at given Yt
    
    aPrediction(t)=aUpdate(t-1); %at+1|t again using the fact that T is identity
    P_Prediction(t)=P_Update(t-1)+phi; %variance of at+1|t using the fact that R is identity and phi = Q
end

% last round
vT=yStar(T)-aPrediction(T);
    
FT=P_Prediction(T)+H(T);
    
Finv=1/FT;
KT=P_Prediction(T)*Finv;

aUpdate(T)=aPrediction(T)+KT*vT; % since T_T=1
P_Update(T)=P_Prediction(T)*(1-KT);


%% Continue with the Carter Kohn (simulation) recursion %%
drawsAlpha=zeros(T,1);

% startround (t=T)
meanAlpha=aUpdate(T);
varAlpha=P_Update(T);
drawsAlpha(T)=meanAlpha+sqrt(varAlpha)*randn; %draw the last observation from N(meanAlpha(T), varAlpha(T))

% iteratively obtain the draws
for t=T-1:-1:1
    meanAlpha=aUpdate(t)+(P_Update(t)/P_Prediction(t+1))*(drawsAlpha(t+1)-aUpdate(t)); %compute the conditional mean of at|Yn
    varAlpha=P_Update(t)*(1-(P_Update(t)/P_Prediction(t+1))); %compute the conditional variance of at|Yn
    drawsAlpha(t)=meanAlpha+sqrt(varAlpha)*randn; %compute a draw from the normal distribution for at|Yn from N(meanAlpha,varianceAlpha)
end 
    
%% save the draws
aSim=drawsAlpha;

end



