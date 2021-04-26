function [irf_record,D_record,gamma_record,struct_irf_record,irf_estimates,D_estimates,gamma_estimates,strshocks_record,strshocks_estimates]=...
    panel4irf(Yi,Xi,beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,signrestable,signresperiods,Magres,relmagrestable,relmagresperiods,favar)


% because there is one VAR model estimated for each unit, the IRFs will differ across units
% hence, loop over units
for ii=1:N

% first run the Gibbs sampler to obtain posterior draws
irf_record(:,:,ii)=irf(beta_gibbs(:,:,ii),It,Bu,IRFperiods,n,m,p,k);

   % if IRFs have been set to an unrestricted VAR (IRFt=1):
   if IRFt==1
   % run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
   [D_record(:,:,ii),gamma_record(:,:,ii)]=irfunres(n,It,Bu,sigma_gibbs(:,:,ii));
   struct_irf_record=[];
   % compute posterior estimates
   [irf_estimates(:,:,ii),D_estimates(:,:,ii),gamma_estimates(:,:,ii)]=irfestimates(irf_record(:,:,ii),n,IRFperiods,IRFband,IRFt,[],[],favar);

   % if IRFs have been set to an SVAR with Choleski identification (IRFt=2):
   elseif IRFt==2
   % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
   [struct_irf_record(:,:,ii),D_record(:,:,ii),gamma_record(:,:,ii)]=irfchol(sigma_gibbs(:,:,ii),irf_record(:,:,ii),It,Bu,IRFperiods,n,favar);
   % compute posterior estimates
   [irf_estimates(:,:,ii),D_estimates(:,:,ii),gamma_estimates(:,:,ii)]=irfestimates(struct_irf_record(:,:,ii),n,IRFperiods,IRFband,IRFt,D_record(:,:,ii),gamma_record(:,:,ii),favar);
   
   % if IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
   elseif IRFt==3
   % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
   [struct_irf_record(:,:,ii),D_record(:,:,ii),gamma_record(:,:,ii)]=irftrig(sigma_gibbs(:,:,ii),irf_record(:,:,ii),It,Bu,IRFperiods,n,favar);
   % compute posterior estimates
   [irf_estimates(:,:,ii),D_estimates(:,:,ii),gamma_estimates(:,:,ii)]=irfestimates(struct_irf_record(:,:,ii),n,IRFperiods,IRFband,IRFt,D_record(:,:,ii),gamma_record(:,:,ii),favar);
   
   % if IRFs have been set to an SVAR with sign restrictions
   elseif IRFt==4
   if Magres==1 %this should be adjusted to strctident options
   [struct_irf_record(:,:,ii),D_record(:,:,ii),gamma_record(:,:,ii)]=irfres_relmagnitude_panel(beta_gibbs(:,:,ii),sigma_gibbs(:,:,ii),It,Bu,IRFperiods,n,m,p,k,signrestable,signresperiods,relmagrestable,relmagresperiods);
   % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
   else
   [struct_irf_record(:,:,ii),D_record(:,:,ii),gamma_record(:,:,ii)]=irfsignrespanel(beta_gibbs(:,:,ii),sigma_gibbs(:,:,ii),It,Bu,IRFperiods,n,p,m,k,signrestable,signresperiods);
   end
   % compute posterior estimates
   [irf_estimates(:,:,ii),D_estimates(:,:,ii),gamma_estimates(:,:,ii)]=irfestimates(struct_irf_record(:,:,ii),n,IRFperiods,IRFband,IRFt,D_record(:,:,ii),gamma_record(:,:,ii),favar);
   end

end



% also, if a s structural identification was implemented, compute structural shocks
strshocks_record={};
strshocks_estimates={};
if IRFt~=1
   % because shocks have to be computed for each unit, loop over units
   for ii=1:N
   % run the Gibbs sampler
   strshocks_record(:,:,ii)=strshocks(beta_gibbs(:,:,ii),D_record(:,:,ii),Yi(:,:,ii),Xi(:,:,ii),n,k,It,Bu,favar); 
   % obtain point estimates and credibility intervals
   strshocks_estimates(:,:,ii)=strsestimates(strshocks_record(:,:,ii),n,T,IRFband);
   end    
end


































