function result=RS_PF_Rationality(m,forecasterror,x,pdate)
%%   INPUT: 
%%   m = size of rolling window
%%	forecastserror = actual - forecast
%%	x is the variable you want to test coefficients equal to zero
%%   pdate is the vector of dates

T=length(forecasterror);
if m>=T
    err_dlg = errordlg('The window size of the Rossi-Sekhposyan (JAE,2016) test cannot be equal to or larger than the forecasted sample.');
    waitfor(err_dlg);
elseif m==0
    err_dlg = errordlg('The window size of the Rossi-Sekhposyan (JAE,2016) test cannot be equal to zero.');
    waitfor(err_dlg);
end

cvtable = [       
      NaN     0.1000    0.2000    0.3000    0.4000    0.5000    0.6000    0.7000    0.8000    0.9000
    1.0000   10.5066    9.0503    8.0245    7.1035    6.3957    5.6112    5.1113    4.6141    3.9748
    2.0000   21.2392   18.0544   15.8290   13.9122   13.0720   11.1526   10.4549    9.0570    7.8723
    3.0000   31.4497   26.8866   23.7832   21.4577   19.6097   17.4180   15.3225   13.5010   11.4381
    4.0000   43.5150   36.9028   32.8187   28.4075   25.1774   23.3645   20.5785   17.6700   15.5384
    5.0000   52.4148   45.7998   39.6896   35.7848   32.0200   28.4850   26.2204   23.1738   19.1090
    6.0000   62.6771   54.3749   47.4711   42.4503   38.4920   34.9394   30.4063   27.9807   23.8787
    7.0000   74.8406   62.3659   56.2449   49.0721   44.4213   39.6189   36.4280   33.0852   26.9654
    8.0000   84.5728   72.8813   63.2267   56.8973   51.5069   45.7856   41.3975   36.7853   31.2008
    9.0000  109.6177   95.3818   87.2701   77.9691   72.5004   63.5162   60.0533   51.9429   47.0975
   10.0000  122.4825  107.9759   94.2844   88.3139   80.2026   71.6698   67.4220   58.3127   54.7817 ];

P     = size(forecasterror,1); 
mu    = m/P; 
cvcol = round(mu*10)+1;

if cvcol==1;
    cvcol = 2;
end; 

if cvcol>10; 
    cvcol = 10; 
end;

nreg = size(x,2); 
cv   = cvtable(nreg+1,cvcol);

resultt=[];
for t=m:P
    % Calculate OLS Wald-Test 
    out     = RS_PF_OLS_Wald(forecasterror(t-m+1:t,:),x(t-m+1:t,:)); 
    resultt = [resultt;out];
end;

ptruncdate = pdate(m:end,1);

result.MZ         = max(resultt);
result.cv         = cv;
result.ptruncdate = ptruncdate;
result.resultt    = resultt(:,1);
result.cvones     = cv*ones(size(resultt,1),1);
