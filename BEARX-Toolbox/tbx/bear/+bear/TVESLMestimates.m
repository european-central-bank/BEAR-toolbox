function [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound, Psi_median, Psi_lbound, Psi_ubound, Ycycle_median, Ycycle_lbound, Ycycle_ubound, sbar, L_median]=TVESLMestimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,n,T,cband, Psi_gibbs,YincLags,p, L_gibbs)




q=size(beta_gibbs,1);

% compute the median, standard deviation, and credibility intervals for the posterior distribution of beta
for ii=1:q
beta_median(ii,1)=[quantile(beta_gibbs(ii,:),0.5)];
beta_std(ii,1)=std(beta_gibbs(ii,:));
beta_lbound(ii,:)=[quantile(beta_gibbs(ii,:),(1-cband)/2)];
beta_ubound(ii,:)=[quantile(beta_gibbs(ii,:),1-(1-cband)/2)];
end


% compute the results for sigma (long-run value)
sigma_median=reshape(quantile(sigma_gibbs,0.5,2),n,n);


% compute the rsults for sigma (sample values)
sigma_t_median=cell(n,n);
sigma_t_lbound=cell(n,n);
sigma_t_ubound=cell(n,n);
% loop over periods and entries
for ii=p+1:T
   for jj=1:n
      for kk=1:jj
      sigma_t_median{jj,kk}(ii-p,1)=quantile(sigma_t_gibbs{ii,1}(jj,kk,:),0.5,3);
      sigma_t_lbound{jj,kk}(ii-p,1)=quantile(sigma_t_gibbs{ii,1}(jj,kk,:),(1-cband)/2,3);
      sigma_t_ubound{jj,kk}(ii-p,1)=quantile(sigma_t_gibbs{ii,1}(jj,kk,:),1-(1-cband)/2,3);
      end
   end
end
%finally use the symetrie of the VCV
for jj=1:n
    for kk=1:n
        if jj~=kk
          sigma_t_median{jj,kk}=sigma_t_median{kk,jj};
          sigma_t_lbound{jj,kk}=sigma_t_lbound{kk,jj}; 
          sigma_t_ubound{jj,kk}=sigma_t_ubound{kk,jj}; 
        end
    end 
end

%estimate the estimates of the trend
% compute the median, standard deviation, and credibility intervals for the posterior distribution of beta
for ii=1:n
    for kk=p+1:T
Psi_median(kk-p,ii)=[quantile(Psi_gibbs{1,ii}(kk,:),0.5)];
Psi_lbound(kk-p,ii)=[quantile(Psi_gibbs{1,ii}(kk,:),(1-cband)/2)];
Psi_ubound(kk-p,ii)=[quantile(Psi_gibbs{1,ii}(kk,:),1-(1-cband)/2)];
    end 
end

Ycycle_median = YincLags(p+1:end,:)-Psi_median;
Ycycle_lbound = YincLags(p+1:end,:)-Psi_lbound;
Ycycle_ubound = YincLags(p+1:end,:)-Psi_ubound;

%get sbar as the mean values of the periodwhise medians

% loop over periods and entries
for ii=p+1:T
   for jj=1:n
      L_median(ii,jj)=quantile(L_gibbs(ii,jj,:),0.5,3);
    end
end

for ii=1:n
    sbar(ii,1)=median(L_median(:,ii));
end 
end 


