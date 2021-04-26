function [irf_record,D_record,gamma_record,struct_irf_record,irf_estimates,D_estimates,gamma_estimates,strshocks_record,strshocks_estimates]=...
    panel6irf(y,Xtilde,theta_gibbs,sigma_gibbs,B_gibbs,Xi,It,Bu,IRFperiods,IRFband,IRFt,rho,thetabar,N,n,m,p,T,d,favar)








% create first the cells storing the results
irf_record={};
irf_estimates={};

% deal with shocks in turn (there are N*n shocks with this model)
for ii=1:N*n

   % start iterating
   for jj=1:It-Bu

   % draw theta from its posterior distribution
   theta=theta_gibbs(:,jj,T);

   % draw B from its posterior distribution
   B=reshape(B_gibbs(:,jj),d,d);
   % obtain its Choleski factor: as B is diagonal, it is simply the square roots of its diagonal entries
   cholB=sparse(diag((diag(B).^0.5)));

   % create a matrix of zeros of dimension p*(N*n)
   Ysim=zeros(p,N*n);
   %  step 2: set the value of the last row, column i, equal to 1
   Ysim(p,ii)=1;

      % step 4: for each iteration kk, repeat the algorithm for periods T+1 to T+h
      for kk=1:IRFperiods-1

      % recover theta for period T+kk
      theta=(1-rho)*thetabar+rho*theta+cholB*mvnrnd(zeros(d,1),eye(d))';

      % use the function lagx to obtain a matrix temp, containing the endogenous regressors
      temp=lagx(Ysim,p-1);

      % define the vector X for the period
      Xsim_t=[temp(end,:) zeros(1,m)];

      % obtain Xbar_t et Xtilde_t
      Xbar_t=kron(speye(N*n),Xsim_t);
      Xtilde_t=Xbar_t*Xi;

      % obtain the predicted value for T+kk
      yp=Xtilde_t*theta;

      % concatenate yp at the top of Y
      Ysim=[Ysim;yp'];

      % repeat until values are obtained for T+h
      end

      % record the results from current iteration in cell irf_record
      % loop over variables
      for kk=1:N*n
      % consider column kk of matrix Ysim and trim the (p-1) initial periods: what remains is the series of IRFs for period T to period T+h-1, for variable kk
      temp=Ysim(p:end,kk);
      % record these values in the corresponding matrix of irf_record
      irf_record{kk,ii}(jj,:)=temp';
      end

   % then go for next iteration
   end

% conduct the same process with shocks in other variables
end






% then apply the structural decomposition (if applicable)
% if IRFs have been set to an unrestricted VAR (IRFt=1):
if IRFt==1
% generate empty structural IRFs (just to be consistent with subsequent parts of the code
struct_irf_record=[];
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(irf_record,N*n,IRFperiods,IRFband,IRFt,[],[],favar);
% if IRFs have been set to an SVAR with Choleski identification (IRFt=2):
elseif IRFt==2
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record,D_record,gamma_record]=irfchol(sigma_gibbs(:,:,T),irf_record,It,Bu,IRFperiods,N*n,favar);
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,N*n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
% if IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
elseif IRFt==3
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record,D_record,gamma_record]=irftrig(sigma_gibbs(:,:,T),irf_record,It,Bu,IRFperiods,N*n,favar);
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,N*n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
end




% record the structural decomposition matrices (the ones obtained from the structural decomposition function only apply to the final period, but incoming functions will require records for all the periods)
% also, if a structural identification was implemented, compute structural shocks
strshocks_record={};
strshocks_estimates={};
% in the case of no structural decomposition
if IRFt==1
% run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
D_record=repmat(reshape(eye(N*n),(N*n)^2,1),[1 It-Bu T]);
gamma_record=sigma_gibbs;
% obtain estimates
D_estimates=repmat(reshape(eye(N*n),(N*n)^2,1),[1 1 T]);
   for ii=1:T
   gamma_estimates(:,1,ii)=quantile(gamma_record(:,:,ii),0.5,2);
   end
elseif IRFt==2
% run the Gibbs sampler
[strshocks_record,D_record,gamma_record]=strshockspan6(theta_gibbs,sigma_gibbs,y,Xtilde,N,n,T,It,Bu,IRFt); 
% obtain point estimates and credibility intervals
[strshocks_estimates]=strsestimates(strshocks_record,N*n,T,IRFband);
% reshape
strshocks_estimates=reshape(strshocks_estimates,[n 1 N]);
% obtain estimates
   for ii=1:T
   D_estimates(:,1,ii)=quantile(D_record(:,:,ii),0.5,2);
   end
gamma_estimates=repmat(reshape(eye(N*n),(N*n)^2,1),[1 1 T]);
elseif IRFt==3
% run the Gibbs sampler
[strshocks_record,D_record,gamma_record]=strshockspan6(theta_gibbs,sigma_gibbs,y,Xtilde,N,n,T,It,Bu,IRFt); 
% obtain point estimates and credibility intervals
[strshocks_estimates]=strsestimates(strshocks_record,N*n,T,IRFband);
% reshape
strshocks_estimates=reshape(strshocks_estimates,[n 1 N]);
% obtain estimates
   for ii=1:T
   D_estimates(:,1,ii)=quantile(D_record(:,:,ii),0.5,2);
   gamma_estimates(:,1,ii)=quantile(gamma_record(:,:,ii),0.5,2);
   end
end

