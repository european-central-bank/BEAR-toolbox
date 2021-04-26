function [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]...
    =panel2irf(Ymat,Xmat,beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,Y,X,signreslabels,FEVDresperiods,data_exo,const,exo,IRFt,strctident,favar,signrestable,signresperiods)







% because there is only one model, there is no need to loop over units
% hence, estimate the IRFs for the model, as with a standard normal-Wishart
% first run the Gibbs sampler to obtain posterior draws
[irf_record]=irf(beta_gibbs,It,Bu,IRFperiods,n,m,p,k);

% If IRFs have been set to an unrestricted VAR (IRFt=1):
if IRFt==1
% run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
[D_record, gamma_record]=irfunres(n,It,Bu,sigma_gibbs);
struct_irf_record=[];
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(irf_record,n,IRFperiods,IRFband,IRFt,[],[],favar);
   
% If IRFs have been set to an SVAR with Choleski identification (IRFt=2):
elseif IRFt==2
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record, D_record, gamma_record]=irfchol(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);

% If IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
elseif IRFt==3
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record, D_record, gamma_record]=irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);

% If IRFs have been set to an SVAR with sign restrictions (IRFt=4):
elseif IRFt==4
% run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
[struct_irf_record,D_record,gamma_record]=irfres_old(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,m,p,k,signrestable,signresperiods);
%[struct_irf_record,D_record,gamma_record]=irfsignrespanel(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,p,m,k,signrestable,signresperiods);
%[struct_irf_record,D_record,gamma_record,~,~,~,~]=irfres(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,T,[],[],signreslabels,FEVDresperiods,data_exo,HD,const,exo,strctident,pref,favar,IRFt,It,Bu);

% compute posterior estimates
[irf_estimates,D_estimates,gamma_estimates]=irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar); 

end


% also, if a s structural identification was implemented, compute structural shocks
strshocks_record={};
strshocks_estimates={};
if IRFt~=1
   % because shocks have to be computed for each unit, loop over units
   for ii=1:N
   % run the Gibbs sampler
   strshocks_record(:,:,ii)=strshocks(beta_gibbs,D_record,Ymat(:,:,ii),Xmat(:,:,ii),n,k,It,Bu,favar); 
   % obtain point estimates and credibility intervals
   strshocks_estimates(:,:,ii)=strsestimates(strshocks_record(:,:,ii),n,T,IRFband);
   end    
end


