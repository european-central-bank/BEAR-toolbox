function [beta_gibbs sigma_gibbs]=dogibbs(It,Bu,Bcap,phicap,Scap,alphacap,alphatop,n,k)









% start iterations
for ii=1:It-Bu

% draw B from a matrix-variate student distribution with location Bcap, scale Scap and phicap and degrees of freedom alphatop
B=matrixtdraw(Bcap,Scap,phicap,alphatop,k,n);

% then draw sigma from an inverse Wishart distribution with scale matrix Scap and degrees of freedom alphacap (step 3)
sigma=iwdraw(Scap,alphacap);

% record values before starting next iteration
beta_gibbs(:,ii)=B(:);
sigma_gibbs(:,ii)=sigma(:);

% go for next iteration
end


