function [strshocks_record]=TVEmastrshocks(beta_gibbs,theta_gibbs,D_record,n,k1,It,Bu,TVEH,indH,data_endo,p)











% first create the call storing the results
strshocks_record=cell(n,1);
T=length(data_endo);

% then loop over iterations
for ii=1:It-Bu

% recover the VAR coefficients, reshaped for convenience
B=reshape(beta_gibbs(:,ii),k1,n);

theta=theta_gibbs(:,ii);
for it=1:T
    eq(it,:)=(squeeze(TVEH(:,:,indH(it),it))*theta)'; % compute the equilibrium values given theta
end

temp2=data_endo-eq;
temp3=lagx(temp2,p);
Yhat=temp3(:,1:n);
Xhat=temp3(:,n+1:end);


% obtain the residuals from (XXX)
EPS=Yhat-Xhat*B;

% then recover the structural marix D
D=reshape(D_record(:,ii),n,n);


% obtain the structural disturbances from (XXX)
ETA=D\EPS';


   % save in struct_shocks_record
   for jj=1:n
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end


end


