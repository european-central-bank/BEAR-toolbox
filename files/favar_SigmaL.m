function [Sigma,L]=favar_SigmaL(Sigma,L,nfactorvar,numpc,onestep,n,favar_X,FY,a0,b0,T,lags,L0)

% Sample Sigma and L for favar gibbs sampler
for jj=1:nfactorvar
    if onestep==1
    if jj <= numpc
        Ld=zeros(n,1);
        Ld(jj)=1;
    else
        Ld=favar_olssvd(favar_X(:,jj),FY);
    end
    elseif onestep==0
        Ld=L(jj,:)';
    end
    ed=favar_X(:,jj)-FY*Ld;
    
    % draw Sigma(n,n)
%     a_bar=a0+ed'*ed+Ld'*inv(inv(L0)+inv(FY'*FY))*Ld;
    a_bar=a0+ed'*ed+Ld'/(inv(L0)+inv(FY'*FY))*Ld;
    b_bar=b0+T+lags;
%     % draw Sigma from inverse Gamma distribution
%     Sigmad=igrandn(b_bar/2,a_bar/2);
    
    % alternatively sample from Chi square distribution (equivalent to above, adjust prior values as the terms are not /2)
        Sigmad=chi2rnd(b_bar);
        Sigmad=a_bar/Sigmad;
    
    Sigma(jj,jj)=Sigmad;
    if onestep==1
    % draw L(n,1:n):
    if jj > numpc
        L_bar=inv(L0+FY'*FY);
        L_barmean=L_bar*(FY'*FY)*Ld;
        Ld=L_barmean'+randn(1,n)*chol(Sigma(jj,jj)*L_bar);
%         % should be quasi equivalent
%             L_bar=L0+FY'*FY;
%             L_barmean=L_bar\(FY'*FY)*Ld;
%             Ld=L_barmean'+randn(1,n)*chol(Sigma(jj,jj))/L_bar';
        L(jj,1:n)=Ld;
    end
    end
end