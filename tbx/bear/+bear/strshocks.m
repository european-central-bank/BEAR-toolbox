function [strshocks_record]=strshocks(beta_gibbs,D_record,Y,X,n,k,It,Bu,favar)

% first create the call storing the results
strshocks_record=cell(n,1);
Bgibbs=reshape(beta_gibbs,k,n,It-Bu);
Dgibbs=reshape(D_record,n,n,It-Bu);

% recall X and Y from the sampling process in this case
if favar.FAVAR==1
    if isfield(favar,'bvarXY')==1
        bvarXY=1;
        Xgibbs=reshape(favar.X_gibbs,size(X,1),size(X,2),It-Bu);
        Ygibbs=reshape(favar.Y_gibbs,size(Y,1),size(Y,2),It-Bu);
    else
        bvarXY=0;
    end
else
    bvarXY=0;
end

% then loop over iterations
for ii=1:It-Bu
    
    % recover the VAR coefficients, reshaped for convenience
    B=squeeze(Bgibbs(:,:,ii));
    
    if bvarXY==1
        X=squeeze(Xgibbs(:,:,ii));
        Y=squeeze(Ygibbs(:,:,ii));
    end
    
    % obtain the residuals from (XXX)
    EPS=Y-X*B;
    
    % then recover the structural marix D
    D=squeeze(Dgibbs(:,:,ii));
    
    % obtain the structural disturbances from (XXX)
    ETA=D\EPS';
    
    % save in struct_shocks_record
    for jj=1:n
        strshocks_record{jj,1}(ii,:)=ETA(jj,:);
    end
    
end

