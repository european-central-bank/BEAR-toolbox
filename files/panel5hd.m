function [hd_record,hd_estimates]=panel5hd(Xi,theta_gibbs,D_record,strshocks_record,It,Bu,Ymat,Xmat,N,n,m,p,k,T,HDband)









% first recover a VAR in standard form from the structural factors (required to use the hdecomp function)
beta_gibbs=Xi*theta_gibbs;
% then run the gibbs sampler to obtain draws for historical decomposition
[hd_record]=hdecomp(beta_gibbs,D_record,strshocks_record,It,Bu,Ymat,Xmat,N*n,m,p,k,T);
% then obtain point esimates and credibility intervals
[hd_estimates]=hdestimates(hd_record,N*n,T,HDband);
















