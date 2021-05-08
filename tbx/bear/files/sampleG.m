function [Gdraw, phi_Gdraw] = sampleG(zData, Psi, CD, phi_G, Gold, priorValues, dataValues)
% This function takes a draw from the conditional posterior of the variance G of the SV in the second measurement equation.
%sampleG(zData_prop,PsiDraw_prop,CDdraw,phi_Gdraw,Gdraw,priorValues,dataValues)
%zData=zData_prop; 
%Psi = PsiDraw_prop;
%CDdraw = CD;
%phi_G = phi_Gdraw;
%Gold=Gdraw;

%% Initialize
offset_c = priorValues.offset_c; %value to offset problems with ln(0)

[T,Mz] = size(zData);
Ppsi = dataValues.Ppsi;

C = CD(1:Mz); % collect the first Mz (number of survey data) rows of CD with C as the constant of the 
D = diag(CD(Mz+1:2*Mz)); %D is the matrix describing the random walk for the measurement equation

% obtain prior data
%prior data for mean process
startMeanVector=priorValues.mean_ln_g0;
startVarVector =priorValues.var_ln_g0;

%prior data for standard deviation
priorPhi_G=priorValues.phi_g;
priorD_G  =priorValues.d_g;


%% Prepare Sampling
Gvars=zeros(T,Mz); %time varrying VCV
phi_Gdraw=zeros(Mz,1); %Variance of the process generating the time variation 

zDiff = (zData'-repmat(C,1,T)-D*Ppsi*Psi')'; %calculate difference between survey data and predicted state

for i=1:Mz
    zEntry=sum(isnan(zDiff(:,i)))+1; %get the first survey data observation
    
    % prepare for each i
    residsTemp=zDiff(zEntry:T,i);  %cut the residuals
    yStar=log(residsTemp.^2+offset_c);   %transform the residuals into log squared
    phi=phi_G(i); %get the standard deviation of the stochastic volatility process for this particular equation  
    lnSigma2=log(Gold(zEntry:T,i)); % note log => h = ln sigma2 and Gold is the previous estimate of G (the VCV of the measurement equation)
    
    startMean=startMeanVector(i);
    startVar=startVarVector(i);
    
    % sample states
    [yStarAdj, Ht] = statesMix(yStar,lnSigma2); %get the mean and variance adjusted mixture of the states
    
    % sample log variances conditional on the state of the variable
    %run the kalman filter/smoother on the mean and variance adjusted
    %residuals of the measurement equation to sample the variance
    %covariance matrix
    [logVarsDraw_Gi]=KF_CKsimSV(yStarAdj,Ht,phi,startMean,startVar);
    Gvars(:,i)=exp([zeros(1,zEntry-1) logVarsDraw_Gi']');
    
    % sample phi
    [phiDraw_Gi]=samplePhi(logVarsDraw_Gi,priorD_G,priorPhi_G);
    phi_Gdraw(i)=phiDraw_Gi;   
end


%% Construct G
% Gdraw=zeros(Mz,Mz,T);
% 
% for i=1:Mz
%     Gdraw(i,:)=Gvars(:,i);
% end
 
Gdraw=Gvars;
end

