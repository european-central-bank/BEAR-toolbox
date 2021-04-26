function [dic]=dic_test(Y,X,N,beta_gibbs,sigma_gibbs,Acc,favar)


%This function calculates the Deviance Information Criteria.
%Introduced in Spiegelhalter et al.(2002), the DIC is a generalization of the Akaike information criterion —
%it penalizes model complexity while rewarding fit to the data


likelihood=[];

beta_dic=beta_gibbs';
sigma_dic=reshape(sigma_gibbs,N,N,Acc);
par=size(beta_dic,2)/N; % get the number of parameters per equation to be used in the reshape function
% recall X and Y from the sampling process in this case, analogue to beta and sigma
if favar.FAVAR==1
Xgibbs_dic=reshape(favar.X_gibbs,size(X,1),size(X,2),Acc);
Ygibbs_dic=reshape(favar.Y_gibbs,size(Y,1),size(Y,2),Acc);
end

%calculate the likelihood for each saved draw

for i=1:size(beta_dic,1)
    sigma=squeeze(sigma_dic(:,:,i));
    
    if favar.FAVAR==1
    X=squeeze(Xgibbs_dic(:,:,i));
    Y=squeeze(Ygibbs_dic(:,:,i));
    end

    [l,problem]=loglik(reshape(beta_dic(i,:),par,N),sigma,Y,X);%likelihood linear model
    if problem
      break 
      
    end
   
    likelihood=[likelihood;l];
end

if problem
    dic='NaN';
else
    
%get the posterior mean for the parameters
betam= squeeze(mean(beta_dic,1));
sigmam=squeeze(mean(sigma_dic,3));

if favar.FAVAR==1
X=squeeze(mean(Xgibbs_dic,3));
Y=squeeze(mean(Ygibbs_dic,3));
end
%Calculate the loglikelihood at the posterior mean

D_mean=-2*loglik(reshape(betam,par,N),sigmam,Y,X);%the likelihood evaluated at the posterior mean

% Calculate the effective number of parameters
D=squeeze(mean(-2*likelihood));% the mean of the likelihood evaluated at each saved draw
params=D-D_mean;

%Calculate the DIC 
dic=D+params;
end
end

