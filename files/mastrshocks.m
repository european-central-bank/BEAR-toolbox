function [strshocks_record]=mastrshocks(beta_gibbs,delta_gibbs,D_record,Y,X,Z,n,k1,k3,It,Bu)











% first create the call storing the results
strshocks_record=cell(n,1);


% then loop over iterations
for ii=1:It-Bu

% recover the VAR coefficients, reshaped for convenience
B=reshape(beta_gibbs(:,ii),k1,n);
Delta=reshape(delta_gibbs(:,ii),k3,n);

% obtain the residuals from (XXX)
EPS=Y-X*B-Z*Delta;

% then recover the structural marix D
D=reshape(D_record(:,ii),n,n);


% obtain the structural disturbances from (XXX)
ETA=D\EPS';


   % save in struct_shocks_record
   for jj=1:n
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end


end


