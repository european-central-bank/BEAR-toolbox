function [Fluctuation_Test,cvlow,cvup,tforgraph,cvupplot,cvlowplot]=GR_PF_Fluctuation(y1,y,actualdata,max_nlag,dates,windowSize,aalpha,ttype);
%Giacomini-Rossi's JAE(2010) Fluctuation test
%INPUT: windowSize is the size of the rolling window
%       aalpha=significance level (e.g. 0.05 for a 5% -- it can be 0.05 or 0.10)

T=length(y1); Fluctuation_Test=[]; 
if windowSize>=T
    err_dlg = errordlg('The window size of the Giacomini-Rossi JAE(2010) test cannot be equal to or larger than the forecasted sample.');
    waitfor(err_dlg);
elseif windowSize==0
    err_dlg =errordlg('The window size of the Giacomini-Rossi JAE(2010) test cannot be equal to zero.');
    waitfor(err_dlg);    
end

for j=windowSize:1:T; 
    sq_forcast_error_model = (y1(j-windowSize+1:j)-actualdata(j-windowSize+1:j)).^2;     % 2018_06_18: squared FE from model   
    sq_forcast_error_bench = (y(j-windowSize+1:j)-actualdata(j-windowSize+1:j)).^2;      % 2018_06_18: squared FE from benchmark 
    result=GR_PF_DMtest(sq_forcast_error_model,sq_forcast_error_bench,max_nlag);        % 2018_06_18: conduct test on squared FE differences
        
    % result=GR_PF_DMtest(y1(j-windowSize+1:j),y(j-windowSize+1:j),max_nlag);
DM=result.teststat;  
Fluctuation_Test=[Fluctuation_Test; DM];
end; 
P=T;
M=length(Fluctuation_Test);

%   window/T 2-sided 5%,10% 1-sided 5%,10% 
cvtable=[0.1, 3.393, 3.170, 3.176, 2.928; 
         0.2, 3.179, 2.948, 2.938, 2.676;
         0.3, 3.012, 2.766, 2.770, 2.482;
         0.4, 2.890, 2.626, 2.624, 2.334;
         0.5, 2.779, 2.500, 2.475, 2.168;
         0.6, 2.634, 2.356, 2.352, 2.030;
         0.7, 2.560, 2.252, 2.248, 1.904;
         0.8, 2.433, 2.130, 2.080, 1.740;
         0.9, 2.248, 1.950, 1.975, 1.600];
     
if ttype==2 % two-sided
    if aalpha==0.05; 
        j=2; 
    elseif aalpha==0.10; 
        j=3; 
    end;
elseif ttype==1 % one-sided
    if aalpha==0.05; 
        j=4; 
    elseif aalpha==0.10; 
        j=5; 
    end;    
end

mu=(ceil((windowSize/P)*10))/10; i=mu*10;

if (mu>=0 && mu<0.1)
    mu=0.1;
elseif (mu>0.9 && mu<=1)
    mu=0.9;
end

cv=cvtable(i,j); 
tforgraph2=filter(ones(1,windowSize)/windowSize,1,dates); 
tforgraph=tforgraph2(windowSize:end,:);

cvlow=-cv*ones(T,1); cvup=cv*ones(T,1); 
cvupplot=cv*ones(M,1);
cvlowplot=-cv*ones(M,1); 




