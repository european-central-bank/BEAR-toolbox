function R2=favar_R2(favarX,FY,L,favarplotX_index)
% compute R2 (Coefficient of Determination) for plotX variables, share of
% variance explained by the common component
% 	b=favar_olssvd(favarX,FY);
    L_plotX=L(favarplotX_index,:)';
    resid=favarX-FY*L_plotX;
     SSR=sum(resid.^2);
     TSS=sum(favar_demean(favarX).^2);
     R2=1-(SSR./TSS);