function RS_DF(actualdata, gridDF, Bu, forecasts_dist, ind_feval, ind_deval, hstep, el, bootMC)
%% Density Forecast Evaluation

% Number of Observations in Forecasted Sample
T = size(actualdata,2); 
% 
% % Create Vector of Dates for Plotting
% date_vec = date;
% startdate = char(date_vec(end-numt+1,:));
% enddate   = char(date_vec(end,:));
% [pdate,stringdate] = bear.genpdate(names,0,frequency,startdate,enddate);


%% Rossi-Sekhposyan (2016) Tests for Correct Specification of Forecast Densities

%% Construct Density Probabilities Corresponding to Grid

densitygrid = zeros(T,length(gridDF)-1);
draws = Bu;

for i=1:T
       
    for j = 1:length(gridDF)-1
        
        obj = forecasts_dist(:,ind_feval(1),i);

        logic = sum((gridDF(j)<=obj) & (obj<gridDF(j+1)));
        num = sum(logic);
        
        if isempty(num) 
            num = 0;
        end
            
        densitygrid(i,j) = (num/draws)*100;

    end
    
end

 %% Construct Midpoints of Bins in Grid
gridDF_mid = zeros(1,length(gridDF)-1);
for j = 1:length(gridDF)-1
    gridDF_mid(1,j) = (gridDF(j+1)+gridDF(j))/2;
end

%% Obtain PIT Histogram and RS Test-Statistic
result = bear.RS_DF_Test(densitygrid,actualdata(ind_deval(1),:)',gridDF_mid',hstep,el,bootMC); 



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
