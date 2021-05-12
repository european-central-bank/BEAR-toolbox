function [fevd_record,fevd_estimates]=panel6fevd(N,n,T,struct_irf_record,gamma_record,It,Bu,IRFperiods,FEVDband)






% run the Gibbs sampler to obtain FEVD draws
[fevd_record]=fevd(struct_irf_record,gamma_record(:,:,T),It,Bu,N*n,IRFperiods,FEVDband);
% obtain point estimates and credibility intervals
[fevd_estimates]=fevdestimates(fevd_record,N*n,IRFperiods,FEVDband);




















