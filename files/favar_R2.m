function R2=favar_R2(favarX,FY)
% compute R2 (Coefficient of Determination) for plotX variables
	b=favar_olssvd(favarX,FY);
    resid=favarX-FY*b;
     SSR=sum(resid.^2);
     TSS=sum(favar_demean(favarX).^2);
     R2=1-(SSR./TSS);