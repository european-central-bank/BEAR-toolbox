function [Bdraw,statOK]=sampleB(yData,Psi,SV_H,A,p,priorValues)
% This function uses the method proposed by Carriero Clark and Marcellino
% to draw from the conditional posterior distribution of B.
%sampleB(yData,PsiDraw_prop,HvarsDraw_prop,Adraw_prop,p,priorValues)
%Psi = PsiDraw_prop; %local mean
%SV_H = HvarsDraw_prop; %draw for the time varrying diagonal elements of the VCV
%A = Adraw_prop;     %the time invariant component of the VCV

%% Initialize
[T,M] = size(yData);
Tp=T-p; 

% expand prior data
varsH=priorValues.vars;
lambda=priorValues.lambda; %overall tightness
theta=priorValues.theta;   %extra shrinkage for off diagonal elements

%% set up prior variance and mean of B
% Prior mean of B
priorMeanBeta=zeros(M*p,1); %means are equal to zero

% Prior variance of B
priorVarVectors=zeros(M*p,p);

% lag shrinkage
pVector=zeros(p,1);
for j=1:p
    pVector(j)=1/(j^2);
end

varsH=reshape(varsH,M,1);

for i=1:M
    % scale by variance estimates
    vector_iTemp=(varsH(i)*ones(M,1))./varsH;
    vector_iTemp=vector_iTemp*lambda*theta;
    vector_iTemp(i)=vector_iTemp(i)/theta;
    
    % calculate the prior variances
    vector_i=kron(pVector,vector_iTemp);  
    priorVarVectors(:,i)=vector_i;
end


%% Now sample B row-by-row
Ainv=A\eye(M);

Y_Psi=yData-Psi;
Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*mean(yData(1:p,:));
X_Psi = lagmatrix(Y_Psi,1:p);
X_Psi = X_Psi(p+1:end,:);
Y_Psi=Y_Psi(p+1:end,:);


OK=0; % to control for unstable draws

rejections=0;
statOK=1;
% start drawing B
while OK==0    
    
    % initialize
    scaledEpsilon=zeros(Tp,M);
    Bdraw=zeros(p*M,M);
    
    % prepare data for column 1
    y1=Y_Psi(:,1);
    y1Scaled=y1./(SV_H(p+1:T,1).^0.5);
    hScaling1=(SV_H(p+1:T,1).^0.5)*ones(1,p*M);
    X1Scaled=X_Psi./hScaling1;

    % calculate posterior distribution
    postVarBinv=diag(priorVarVectors(:,1).^(-1))+X1Scaled'*X1Scaled;
    postVarB=postVarBinv\eye(M*p);
    postMeanB=postVarB*(diag(priorVarVectors(:,1).^(-1))*priorMeanBeta+X1Scaled'*y1Scaled);
    
    % obtain cholvar
    [cholPostVarBi,testPD]=chol(postVarB);
    if testPD>0
        cholPostVarBi= cholred(postVarB);
        disp('NPD!')
    end
    cholPostVarBi=cholPostVarBi'; % transpose to obtain lower triangular matrix
    
    % sample the column of Bdraw
    Bi_draw=postMeanB+cholPostVarBi*randn(p*M,1);
    Bdraw(:,1)=Bi_draw;
    
    % prepare residuals
    resids_1=y1Scaled-X1Scaled*Bi_draw;
    scaledEpsilon(:,1)=resids_1;
    
    for i=2:M         
        
        % prepare data for column i
        a_vector=Ainv(i,:)';
        yi=Y_Psi(:,i)-scaledEpsilon*a_vector;
        yiScaled=yi./(SV_H(p+1:T,i).^0.5);
        
        hScaling_i=(SV_H(p+1:T,i).^0.5)*ones(1,p*M);
        XiScaled=X_Psi./hScaling_i;
        
        % calculate posterior distribution
        postVarBinv=diag(priorVarVectors(:,i).^(-1))+XiScaled'*XiScaled;
        postVarB=postVarBinv\eye(M*p);
        postMeanB=postVarB*(diag(priorVarVectors(:,i).^(-1))*priorMeanBeta+XiScaled'*yiScaled);
        
        % obtain cholvar
        [cholPostVarBi,testPD]=chol(postVarB);
        if testPD>0
            cholPostVarBi= cholred(postVarB);
            disp('NPD!')
        end
        cholPostVarBi=cholPostVarBi'; % transpose to obtain lower triangular matrix

        % sample the column of Bdraw
        Bi_draw=postMeanB+cholPostVarBi*randn(p*M,1);
        Bdraw(:,i)=Bi_draw;
        
        % prepare residuals
        resids_i=yiScaled-XiScaled*Bi_draw;
        scaledEpsilon(:,i)=resids_i;   
    end
             
    % check stability    
    [ max_vTemp ] = determineEV(Bdraw,M,p);
    max_v=abs(max_vTemp);

    if max_v <0.999
        OK=1; % accept the draw
    else
        rejections=rejections+1;
        %disp([max_v rejections])
        if rejections>1000
%             disp('Redo This round')
            statOK=0;
            OK=1;
        end

    end
    
 
end

end