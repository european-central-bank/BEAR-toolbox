function [fmat ortirfcell]=panel6cfsim(theta_iter,D_iter,Xi,ybarT,data_exo_p,Fperiods,N,n,m,p,k)











% first recover the set of At matrices, Cbart matrices, and xbart vectors
% initiate At, Cbart and xt
At=cell(Fperiods,1);
Cbart=cell(Fperiods,1);
xbart=cell(Fperiods,1);
% recover the series of VAR coefficient beta for all the forecast periods (one column=one period)
beta=Xi*theta_iter;
% reshape to obtain one equation per column
Beta=reshape(beta,k,Fperiods*N*n);
% separate the coefficients related to exogenous variables (the last m rows of each equation)
% from the ones related to endogenous variables (the other entries) in order to be able to obtain At and Cbart
Beta_endo=reshape(Beta(1:end-m,:),[k-m N*n Fperiods]);
Beta_exo=reshape(Beta(end-m+1:end,:),[m N*n Fperiods]);
% then loop over forecast periods to recover the series of matrices
for ii=1:Fperiods
At{ii,1}=sparse([Beta_endo(:,:,ii)';speye(N*n*(p-1)) sparse(N*n*(p-1),N*n)]);
Cbart{ii,1}=sparse([Beta_exo(:,:,ii)';sparse(N*n*(p-1),m)]);
xbart{ii,1}=data_exo_p(ii,:)';
end



% then produce the series of forecasts and impulse response functions
% preliminary element: generate the selection matrix J
J=[speye(N*n) sparse(N*n,N*n*(p-1))];
% then create the cells storing the IRFs and the forecasts
ortirfcell=cell(Fperiods,Fperiods);
fmat=[];



% estimate first the forecasts
% loop over forecasts periods
for hh=1:Fperiods
% compute the first product term
prod1=speye(N*n*p);
   for ii=1:hh
   prod1=prod1*At{1+hh-ii,1};
   end
% multiply by ybarT to obtain the first term
term1=prod1*ybarT;
% obtain the second term
% initiate the summation
summ=sparse(N*n*p,1);
   % loop over summation periods
   for ii=1:hh
   % initiate the product
   prod2=speye(N*n*p);
      % loop over product periods
      for jj=ii:hh-1
      prod2=prod2*At{hh+ii-jj,1};
      end
   % multiply by Cbart*xt and add to summation
   summ=summ+prod2*Cbart{ii,1}*xbart{ii,1};
   end
term2=summ;
% obtain the forecast for the period
fmat(:,hh)=J*(term1+term2);
end
fmat=fmat';


% then compute the period-specific IRFs
% loop over forecast periods
for hh=1:Fperiods
% the first row of the cell represents the term ii=hh in the summation in 273: it is always equal to identity ( and then becomes D once multiplied by the structural matrix)
ortirfcell{1,hh}=D_iter(:,:,hh);
   % loop over IRF periods (the summation term in 272) 
   for ii=1:hh-1
   % initiate the product
   prod3=speye(N*n*p);
      % loop over the periods involved into the product and calculate it
      for jj=ii:hh-1
      prod3=prod3*At{hh+ii-jj,1};
      end
   % recover the matrix of interest from the selection matrix J
   irfmat=full(J*prod3*J');
   % obtain orthogonalised IRFs
   ortirfmat=irfmat*D_iter(:,:,hh);
   % record in IRFcell
   ortirfcell{hh-ii+1,hh}=ortirfmat;
   end
end


