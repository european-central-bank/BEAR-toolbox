function [fevd_record,fevd_estimates]=panel2fevd(struct_irf_record,gamma_record,It,Bu,IRFperiods,n,FEVDband)



% because fevd is obtained from IRFs, and because IRFs are common to all units, fevd can be run only once
[fevd_record]=fevd(struct_irf_record,gamma_record,It,Bu,n,IRFperiods,FEVDband);
% compute posterior estimates
[fevd_estimates]=fevdestimates(fevd_record,n,IRFperiods,FEVDband);