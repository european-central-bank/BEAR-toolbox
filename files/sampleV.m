function [Vdraw, phi_Vdraw]=sampleV(Psi,phi_V,Vold,priorValues,dataValues)
% This function takes a draw from the conditional posterior of the variance
% V of the SV in the local mean.

%% Initialize
offset_c=priorValues.offset_c;

p = find(isnan(Psi(:,1)),1,'last');
[T,M] = size(Psi);
% Ppsi=dataValues.Ppsi;
 
% obtain prior data
startMeanVector=priorValues.mean_ln_v0;
startVarVector=priorValues.var_ln_v0;

priorPhi_V=priorValues.phi_v;
priorD_V  =priorValues.d_v;
 
%% Prepare Sampling

Vvars=zeros(T,M);
phi_Vdraw=zeros(M,1);

% construct VvarsOld
% VvarsOld=zeros(T,M);
% 
% for i=1:M
%     VvarsOld(:,i)=reshape(Vold(i,i,:),T,1,1); 
% end

%% Sample Vvars
for i=1:M
    
    % prepare for each i
        zEntry=p+1;
        
        PsiDiff=Psi(zEntry+1:T,i)-Psi(zEntry:T-1,i);
        
        residsTemp=PsiDiff;
        yStar=log(residsTemp.^2+offset_c);
        phi=phi_V(i);
        lnSigma2=log(Vold(zEntry+1:T,i)); % note log => h = ln sigma2
    
        startMean=startMeanVector(i);
        startVar=startVarVector(i);

        % sample states
        [yStarAdj, Ht] = statesMix(yStar,lnSigma2);
    
        % sample log variances
        [logVarsDraw_Vi]=KF_CKsimSV(yStarAdj,Ht,phi,startMean,startVar);
        Vvars(:,i)=[0.00000001*ones(zEntry,1) ;exp(logVarsDraw_Vi)];
    
        % sample phi
        [phiDraw_Vi]=samplePhi(logVarsDraw_Vi,priorD_V,priorPhi_V);
        phi_Vdraw(i)=phiDraw_Vi; 
   
end
    

%% Construct V
% Vdraw=zeros(M,M,T);
% 
% for i=1:M
%     Vdraw(i,:)=Vvars(:,i);
% end
Vdraw=Vvars;
end

