%% Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test

% Window size for Rossi-Sekhposyan (JAE,2016) fluctuation rationality test, 
% used in computing series of Wald statistics
% rs_pf_windowSize = fT-round(0.2*fT); 

ind_var=find(strcmp((names(1,2:end)),endo(ind_deval(1))));

y = actualdata(ind_var,:)'-forecasts(ind_feval(1),:)'; % construct forecast errors
fT=length(y);
x = [ones(fT,1),forecasts(ind_feval(1),:)'];                 % construct matrix of regressors

result = RS_PF_Rationality(rs_pf_windowSize,y,x,pdate);         % perform rationality test

ptruncdate = result.ptruncdate; % truncated date vector
resultt    = result.resultt;    % test statistic
cvones     = result.cvones;     % critical values


%% Plots

% Actual Data vs Median Forecasts
figure;
subplot(2,2,1);
plot(pdate,actualdata(ind_var,:), 'LineWidth',2)
hold on
plot(pdate,forecasts(ind_feval(1),:),':k','LineWidth',2)
hold off
hleg=legend('Actual','Median Forecast','Location','best');
set(hleg,'Fontsize',8, 'Fontname','Palatino Linotype');
title(strcat([endo(ind_feval) 'Actual and Forecasted Values']),'Fontsize',8,'Fontname','Times New Roman');
axis tight
set(gca,'Fontname','Times New Roman');


% Plot Test Statistic
subplot(2,2,2);
plot(ptruncdate,resultt,ptruncdate,cvones,'r:','LineWidth',3);
xlim([ptruncdate(1) ptruncdate(end)])
ylabel('Test Statistic','fontsize',8,'Fontname','Palatino Linotype');
xlabel('Test rejects forecast rationality if test line is outside critical value line.','fontsize',7,'Fontname','Palatino Linotype');
hleg=legend('Fluctuation Test','5% Critical Value','Location','best');
set(hleg,'Fontsize',8, 'Fontname','Palatino Linotype');
title('Rossi-Sekhposyan(JAE,2016) Fluctuation Rationality Test','Fontsize',8,'Fontname','Palatino Linotype');
set(gca,'Fontname','Palatino Linotype');

