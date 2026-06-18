function [Adraw]=sampleA_H(yData,Psi,B,Hvars,T,priorValues,dataValues)
% This function takes a draw from the conditional posterior distribution of
% A. The algorithm is based on Cogley and Sargent (2005).

%% Initialize
M=size(yData,2); 
p = size(B,1)/M;
Hscaling=Hvars(p+1:T,:).^0.5; %sqrt of the diagonal elements of the H matrix 

% priors
priorVarAscaling=priorValues.priorVarAscaling_H;  %prior variance for the below diagonal elements of A
priorMeanAscaling=priorValues.priorMeanAscaling_H; %prior mean for the below diagonal elements of A 

%% Prepare data
Y_Psi=yData-Psi; %remove local mean 
Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*mean(yData(1:p,:));
X_Psi = lagmatrix(Y_Psi,1:p);
X_Psi = X_Psi(p+1:end,:);
Y_Psi=Y_Psi(p+1:end,:);

V=Y_Psi-X_Psi*B; %generate residuals

%% Sample row-by-row
Atemp=eye(M);

for i=2:M %the first row of A is by construction [1 0 ...M]
    
    Hscaling_i=Hscaling(:,i)*ones(1,M); 
    Vscaled_i=V./Hscaling_i; 
    
    % row data
    zi=Vscaled_i(:,i);  %rescaled residuals
    Zi=-Vscaled_i(:,1:i-1); 
    
    % make row priors
    priorVar_ai=priorVarAscaling*eye(i-1);
    priorMean_ai=priorMeanAscaling*ones(i-1,1);
    
    % determine posterior
    postVar_ai=(Zi'*Zi+(priorVar_ai\eye(i-1)))\eye(i-1); %posterior variance implied by the normality assumption on prior and likelihood
    postMean_ai=postVar_ai*(Zi'*zi+(priorVar_ai\eye(i-1))*priorMean_ai); %posterior mean implied by the normality assumption
 
    % obtain cholvar
    [Cvar,testPD]=chol(postVar_ai);
    if testPD>0
        Cvar= cholred(postVar_ai);
        disp('NPD!')
    end
    Cvar=Cvar'; % transpose to obtain lower triangular matrix
     
    % sample from posterior
    aiDraw=postMean_ai+Cvar*randn(i-1,1);
     
    % save aiDraw
    Atemp(i,1:i-1)=aiDraw';
    
end

%% Save the draw of A
Adraw=Atemp;

end

