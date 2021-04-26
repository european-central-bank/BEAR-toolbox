function checkpriors(m0,C0,H,decimaldates1,data_endo,D)

T=length(decimaldates1);
H=H(:,:,:,end-T+1:end);
data_endo=data_endo(end-T+1:end,:);
D=D(end-T+1:end,:);

[~, indH]=max(D,[],2); % indH is an indicator that select the active equilibrium

% Compute the prior distribution for the equilibria
M=1000; % number of draws to compute the prior distribution for the equilibria
for m=1:M
    theta=mvnrnd(m0',C0); % extract theta from the prior
    for it=1:T
        eq(it,:,m)=(squeeze(H(:,:,indH(it),it))*theta')'; % compute the equilibrium values given theta
    end
end

eqbound=quantile(eq,[0.05 0.5 0.95],3); % compute the distribution (mean and 90% prob interval)

% Plot
%for j=1:size(data_endo,2)
%    figure
%    plot(decimaldates1,data_endo(:,j)) % the data
%    hold on
%    plot(decimaldates1,eqbound(:,j,2),'k-') % the median
%    plot(decimaldates1,eqbound(:,j,1),'k:') % lower percentile
%    plot(decimaldates1,eqbound(:,j,3),'k:') % higher percentile
%    hold off
%end

end