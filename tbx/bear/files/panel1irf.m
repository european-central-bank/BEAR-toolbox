function [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates]=panel1irf(Y,X,N,n,m,p,k,q,IRFt,bhat,sigmahatb,sigmahat,IRFperiods,IRFband)













% create then the cell storing the point estimates and confidence bands
irf_estimates=cell(n,n);
irf_record=cell(n,n);


% compute D, the structural matrix associated to sigma
if IRFt==1
D=eye(n);
gamma=sigmahat;
elseif IRFt==2
D=chol(nspd(sigmahat),'lower');
gamma=eye(n);
elseif IRFt==3
[D,gamma]=triangf(sigmahat);  
end
gamma_estimates=vec(gamma);
D_estimates=vec(D);


% obtain point estimates for orthogonalised IRFs
[~,ortirfmatrix]=irfsim(bhat,D,n,m,p,k,IRFperiods);

% save the results in the cell irf_estimates
% loop over variables
for ii=1:n
   % deal with shocks in turn
   for jj=1:n
      % loop over IRF periods
      for kk=1:IRFperiods
      irf_estimates{ii,jj}(2,kk)=ortirfmatrix(ii,jj,kk);
      end
   end
end


% start the Monte Carlo phase
for ii=1:1000

% draw a random vector beta from its distribution
% if the produced VAR model is not stationary, draw another vector, and keep drawing till a stationary VAR is obtained
beta=bhat+chol(nspd(sigmahatb),'lower')*randn(q,1);
[stationary,~]=checkstable(beta,n,p,k);
   while stationary==0
   beta=bhat+chol(nspd(sigmahatb),'lower')*randn(q,1);
   [stationary,~]=checkstable(beta,n,p,k);
   end

% obtain orthogonalised IRFs from this beta vector
[~,ortirfmatrix]=irfsim(beta,D,n,m,p,k,IRFperiods);

% record the results in the cell irf_record
% loop over variables
   for jj=1:n
      % deal with shocks in turn
      for kk=1:n
         % loop over IRF periods
         for ll=1:IRFperiods
         irf_record{jj,kk}(ii,ll)=ortirfmatrix(jj,kk,ll);
         end
      end
   end
% go for the next iteration
end


% then compute the confidence interval from the bootstrap values

% loop over variables
for ii=1:n
   % deal with shocks in turn
   for jj=1:n
      % loop over time periods
      for kk=1:IRFperiods
      % consider the higher and lower confidence band for the response of variable kk to shock jj at forecast period ll from the bootstrap simulations
      % lower bound
      irf_estimates{ii,jj}(1,kk)=quantile(irf_record{ii,jj}(:,kk),(1-IRFband)/2);
      % upper bound
      irf_estimates{ii,jj}(3,kk)=quantile(irf_record{ii,jj}(:,kk),IRFband+(1-IRFband)/2);
      end
   end
end


% estimate structural shocks (if some SVAR was selected)
strshocks_estimates=[];
if IRFt==2 || IRFt==3
Bhat=reshape(bhat,k,n);
   % loop over units
   for ii=1:N
   % compute first the model residuals
   EPS=Y(:,:,ii)-X(:,:,ii)*Bhat;
   % Then use (XXX) to recover the structural shocks
   ETA=D\EPS';
   % record
   strshocks_estimates(:,:,ii)=ETA;
   end
end










