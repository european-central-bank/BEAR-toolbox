function [strshocks_record D_record gamma_record]=strshockspan6(theta_gibbs,sigma_gibbs,y,Xtilde,N,n,T,It,Bu,IRFt)











% first create the call storing the results
strshocks_record=cell(N*n,1);
D_record=zeros((N*n)^2,It-Bu,T);
gamma_record=zeros((N*n)^2,It-Bu,T);

% then loop over iterations
for ii=1:It-Bu

% recover the structural factors
theta=reshape(theta_gibbs(:,ii,:),[],1);

% obtain the residuals
EPS=reshape(y-Xtilde*theta,N*n,T);
% obtain the series of structural disturbances
% initiate
ETA=[];

   % loop over time periods
   for jj=1:T
   % recover the sigma matrix for the period
   sigma=reshape(sigma_gibbs(:,ii,jj),N*n,N*n);
   % obtain the structural matrix D
      % if IRFt is set to 2, identify D as the Choleski factor
      if IRFt==2
      D=chol(nspd(sigma),'lower');
      gamma=eye(N*n,N*n);
      % if IRFt is set to 3, identify D as the triangular factorisation
      elseif IRFt==3
      [D gamma]=triangf(nspd(sigma));    
      end
   % obtain the structural shocks
   ETA(:,jj)=D\EPS(:,jj);
   % record the structural matrices D and gamma
   D_record(:,ii,jj)=D(:);
   gamma_record(:,ii,jj)=gamma(:);
   end

   % record the shocks
   for jj=1:N*n
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end

end





