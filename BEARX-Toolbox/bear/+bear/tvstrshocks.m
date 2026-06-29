function [strshocks_record]=tvstrshocks(beta_gibbs,D_record,y,Xbar,n,T,It,Bu)











% first create the call storing the results
strshocks_record=cell(n,1);


% then loop over iterations
for ii=1:It-Bu

% recover the VAR coefficients
B=[];
for tt=1:T
B=[B;beta_gibbs{tt,1}(:,ii)];
end
% obtain the residuals from (XXX)
EPS=reshape(y-Xbar*B,n,T)';


% then recover the structural marix D
D=reshape(D_record(:,ii),n,n);


% obtain the structural disturbances from (XXX)
ETA=D\EPS';


   % save in struct_shocks_record
   for jj=1:n
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end


end


