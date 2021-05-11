function [irf_record,D_record,gamma_record,struct_irf_record,irf_estimates,D_estimates,gamma_estimates,strshocks_record,strshocks_estimates]=...
    panel5irf(Y,Xdot,theta_gibbs,sigma_gibbs,Xi,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,favar)










% create first the cells storing the results
irf_record={};
irf_estimates={};

% deal with shocks in turn (there are N*n shocks with this model)
for ii=1:N*n

   % start iterating
   for jj=1:It-Bu

   % draw theta from its posterior distribution
   theta=theta_gibbs(:,jj);

   % create a matrix of zeros of dimension p*(N*n)
   Ysim=zeros(p,N*n);
   %  step 2: set the value of the last row, column i, equal to 1
   Ysim(p,ii)=1;

      % step 4: for each iteration kk, repeat the algorithm for periods T+1 to T+h
      for kk=1:IRFperiods-1

      % use the function lagx to obtain a matrix temp, containing the endogenous regressors
      temp=lagx(Ysim,p-1);

      % define the vector X
      Xsim=[temp(end,:) zeros(1,m)];

      % obtain Xbar et Xtilde
      Xbar=kron(speye(N*n),Xsim);
      Xtilde=Xbar*Xi;

      % obtain the predicted value for T+kk
      yp=Xtilde*theta;

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
% run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
[D_record,gamma_record]=irfunres(N*n,It,Bu,sigma_gibbs);
struct_irf_record=[];
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(irf_record,N*n,IRFperiods,IRFband,IRFt,[],[],favar);
% if IRFs have been set to an SVAR with Choleski identification (IRFt=2):
elseif IRFt==2
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record,D_record,gamma_record]=irfchol(sigma_gibbs,irf_record,It,Bu,IRFperiods,N*n,favar);
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,N*n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
elseif IRFt==3
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record,D_record,gamma_record]=irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,N*n,favar);
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,N*n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
end





% also, if a s structural identification was implemented, compute structural shocks
strshocks_record={};
strshocks_estimates={};
if IRFt~=1
% run the Gibbs sampler
[strshocks_record]=strshockspan5(theta_gibbs,Xi,D_record,Y,Xdot,N*n,k,T,It,Bu); 
% obtain point estimates and credibility intervals
[strshocks_estimates]=strsestimates(strshocks_record,N*n,T,IRFband);
% reshape
strshocks_estimates=reshape(strshocks_estimates,[n 1 N]);
end

























