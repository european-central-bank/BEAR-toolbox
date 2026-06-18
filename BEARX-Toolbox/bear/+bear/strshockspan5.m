function [strshocks_record]=strshockspan5(theta_gibbs,Xi,D_record,Y,Xdot,Nn,k,T,It,Bu)











% first create the call storing the results
strshocks_record=cell(Nn,1);

% then loop over iterations
for ii=1:It-Bu

% recover the structural factors
theta=theta_gibbs(:,ii);

% obtain eyetheta
eyetheta=kron(speye(T),theta);

% obtain the residuals
EPS=Y-Xdot*eyetheta;

% then recover the structural marix D
D=reshape(D_record(:,ii),Nn,Nn);

% obtain the structural disturbances from (XXX)
ETA=D\EPS;

   % save in struct_shocks_record
   for jj=1:Nn
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end

end


