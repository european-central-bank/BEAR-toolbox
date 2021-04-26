function [hd_record,hd_estimates]=panel3hd(beta_gibbs,D_record,strshocks_record,It,Bu,Yi,Xi,N,n,m,p,k,T,HDband)










% initiate the cells storing the results
hd_record={};
hd_estimates={};
% because historical decomposition has to be computed for ach unit, loop over units
for ii=1:N
% run the Gibbs sampler for historical decomposition
hd_record(:,:,ii)=hdecomp(beta_gibbs(:,:,ii),D_record(:,:,ii),strshocks_record(:,:,ii),It,Bu,Yi(:,:,ii),Xi(:,:,ii),n,m,p,k,T);
% then obtain point esimates and credibility intervals
hd_estimates(:,:,ii)=hdestimates(hd_record(:,:,ii),n,T,HDband);
end





















