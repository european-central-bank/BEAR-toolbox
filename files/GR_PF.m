%% Giacomini-Rossi JAE(2010) Fluctuation Test

max_nlag=4;    % maximum lags for DM test
aalpha = 0.05; % significance level

% two competing forecasts AR(p) - with p BIC selected - Forecasts vs selected BEAR model Forecasts
[F,cvlow_1,cvup_1,tforgraph,cvupplot_1,cvlowplot_1]=...     % 2018_06_18: add actualdata as input argument
    GR_PF_Fluctuation(forecasts(ind_feval(1),:)',ols_forecasts(ind_feval(1),:)',actualdata(ind_feval(1),:)',max_nlag,pdate,gr_pf_windowSize,aalpha,1); % one-sided
[~,cvlow_2,cvup_2,~,cvupplot_2,cvlowplot_2]=...             % 2018_06_18: add actualdata as input argument
    GR_PF_Fluctuation(forecasts(ind_feval(1),:)',ols_forecasts(ind_feval(1),:)',actualdata(ind_feval(1),:)',max_nlag,pdate,gr_pf_windowSize,aalpha,2); % two-sided

x=tforgraph;
y=F;

y1_2=cvupplot_2;
y2_2=cvlowplot_2;

y1_1=cvupplot_2;
y2_1=cvupplot_2;

% Fteststat=max(abs(F));
% cvlowFteststat=cvlow(1);
% cvupFteststat=cvup(1);
% stat=[Fteststat,cvlowFteststat,cvupFteststat];


%% Plots

% AR(p) - with p BIC selected - Forecasts vs selected BEAR model Forecasts
figure;
subplot(2,2,1);
plot(pdate,actualdata(ind_var,:), 'LineWidth',2)
hold on
plot(pdate,ols_forecasts(ind_deval(1),:),':', 'LineWidth',2)
hold on
plot(pdate,forecasts(ind_feval(1),:),':k','LineWidth',2)
hold off
hleg=legend('Actual',char(strcat(['OLS AR(' num2str(biclag(ind_feval)) ')'])),'BEAR Forecasts','Location','Best');
set(hleg,'Fontsize',8, 'Fontname','Palatino Linotype');
title(strcat([endo(ind_feval) 'OLS AR vs BEAR Forecasts']),'Fontsize',8,'Fontname','Times New Roman');
axis tight
set(gca,'Fontname','Times New Roman');


% Plot Test Statistic
subplot(2,2,2);
plot(x,y,'LineWidth',3);
hold on;
plot(x,y1_2,'r--','LineWidth',3);
plot(x,y2_2,'r--','LineWidth',3);
hold off;
ylabel('Test Statistic','fontsize',16,'Fontname','Times New Roman');
xlabel({'Equal predictive ability is rejected if the test statistic line is outside the critical value lines.';'(Note that negative values of the test statistic correspond to negative loss differences,';'that is the forecast errors of the model are lower than those of the autoregressive benchmark).'},'fontsize',7,'Fontname','Palatino Linotype');
hleg=legend('Fluctuation Test',[num2str(aalpha*100) '% Critical Value'],'Location','Best');
set(hleg,'Fontsize',8, 'Fontname','Palatino Linotype');
title(strcat([endo(ind_feval) 'Two-Sided Giacomini-Rossi (JAE, 2010) Fluctuation Test']),'Fontsize',8,'Fontname','Times New Roman');
axis tight
set(gca,'Fontname','Times New Roman');

% Plot Test Statistic
subplot(2,2,3);
plot(x,y,'LineWidth',3);
hold on;
plot(x,y1_1,'r--','LineWidth',3);
plot(x,y2_1,'r--','LineWidth',3);
hold off;
ylabel('Test Statistic','fontsize',16,'Fontname','Times New Roman');
xlabel({'If the test statistics is below the CV, the  model forecasts are significantly better than';' AR forecasts (especially during the times in which the statistic is below the boundary lines).';'(Note that negative values of the test statistic correspond to negative loss differences,';'that is the forecast errors of the model are lower than those of the autoregressive benchmark).'},'fontsize',7,'Fontname','Palatino Linotype');
hleg=legend('Fluctuation Test',[num2str(aalpha*100) '% Critical Value'],'Location','Best');
set(hleg,'Fontsize',8, 'Fontname','Palatino Linotype');
title(strcat([endo(ind_feval) 'One-Sided Giacomini-Rossi (JAE, 2010) Fluctuation Test']),'Fontsize',8,'Fontname','Times New Roman');
axis tight
set(gca,'Fontname','Times New Roman');

