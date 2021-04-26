%% Density Forecast Evaluation

% Number of Observations in Forecasted Sample
T = size(actualdata,2); 
% 
% % Create Vector of Dates for Plotting
% date_vec = date;
% startdate = char(date_vec(end-numt+1,:));
% enddate   = char(date_vec(end,:));
% [pdate,stringdate] = genpdate(names,0,frequency,startdate,enddate);


%% Rossi-Sekhposyan (2016) Tests for Correct Specification of Forecast Densities

RS_DF_Feval;


%% Plots
%if pref.plot
% Plot Actual Data vs Median Forecasts

% PIT Histogram
subplot(2,2,3);
hs=result.histogram;
bin=result.bin;
m=result.m;
bar(0:1/bin:1,bin*hs./m,'histc');
title('PIT Histogram','Fontsize',8,'Fontname','Palatino Linotype');
xlim([0 1]);
box on;
set(gca,'Fontname','Palatino Linotype');

% Test Statistic
subplot(2,2,4);
rvec=result.rvec;
ecdf=result.ecdf;
plot(rvec,ecdf,'LineWidth',2)
hold on
if hstep == 1
    plot(rvec,rvec,'r','LineWidth',2);
    hold on
    plot(rvec,rvec + 1.34/sqrt(m),'r:','LineWidth',2);
    hold on
    plot(rvec,rvec - 1.34/sqrt(m),'r:','LineWidth',2);
end    
hold off
xlim([0 1])
ylim([0 1])
grid on
xlabel('Test rejects correct calibration if test line is outside critical value line.','fontsize',7,'Fontname','Palatino Linotype');
ylabel('Test Statistic','fontsize',8,'Fontname','Palatino Linotype')
%legend('Empirical','Theoretical','5% Critical Value','Location','NorthWest');
hleg = legend('Empirical','Theoretical','5% Critical Value','Location','Best');
set(hleg,'Fontsize',8, 'Fontname','Palatino Linotype');
title('Rossi-Sekhposyan(2017) Test','Fontsize',8,'Fontname','Palatino Linotype')
box on
set(gca,'Fontname','Palatino Linotype');


%end %pref.plot
