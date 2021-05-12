function [fevd_record,fevd_estimates]=panel4fevd(N,struct_irf_record,gamma_record,It,Bu,IRFperiods,n,FEVDband)








% initiate the cell storing the values
fevd_record={};
fevd_estimates={};

% as the VAR coefficients are proper to each unit, they will generate different IRFs, and hence different FEVD
% therefore, loop over units
for ii=1:N
[fevd_record(:,:,ii)]=fevd(struct_irf_record(:,:,ii),gamma_record(:,:,ii),It,Bu,n,IRFperiods,FEVDband);
% compute posterior estimates
[fevd_estimates(:,:,ii)]=fevdestimates(fevd_record(:,:,ii),n,IRFperiods,FEVDband);
end

















