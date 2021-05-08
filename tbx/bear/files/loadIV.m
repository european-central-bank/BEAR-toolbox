function [EPSIV,IVcut,EPSt,sigmahatIV,sigma_hat,inv_sigma_hat,IV,txt,OverlapIVinY,cut1,cut2,cut3,cut4]=...
    loadIV(betahat,k,n,Y,X,T,lags,names,startdate,enddate,strctident)

[IV,txt]=xlsread('data.xlsx','IV');

Index=strcmp(txt(1,:),strctident.Instrument);
IVnum=find(Index==1,1,'first')-1;
if isempty(IVnum)||IVnum==0 % check if the IV can be found in the data sheet
   message=['Instrumental variable ' strctident.Instrument ' cannot be found. Please verify that the "IV" sheet of the Excel data file is properly filled.'];
   msgbox(message,'IV error');
   error('programme termination: IV error');  
end
IV=IV(:,IVnum);
NANIV=~isnan(IV); 
IV=IV(NANIV); %IV=IV(~isnan(IV))
% drop IV names from txt
txt=txt(2:length(IV)+1,1);
beginofIV=find(strcmp(strctident.startdateIV,txt));
if isempty(beginofIV)
    beginofIV=1;
end
endofIV=find(strcmp(strctident.enddateIV, txt));
if isempty(endofIV)
    endofIV=length(IV);
end
txt=txt(beginofIV:endofIV,1);
IV=IV(beginofIV:endofIV,1);



%% Preparation for first stage regression

%get reduced form residuals
B    = reshape(betahat,k,n);
EPS  = Y-X*B;
%df = T-lags*n-1; %degrees of freedom

sigma_hat = EPS'*EPS/T;
inv_sigma_hat = inv(sigma_hat);


%check if the IV series is actually longer than the time dimension, meaning
%that it starts earlier
if length(IV) > length(EPS)
    drop = length(IV) - length(EPS); %determine the difference
    IV=IV(drop+1:end,1);
    txt=txt(drop+1:end,1);
end


%Preliminaries
    cut1 = '';
    cut2 = '';
    cut3 = '';
    cut4 = '';

[EPSIV,IVcut,OverlapIVinY,txt]=cut_EPS_IV_GK_new(txt, names, EPS, IV, cut1, cut2, cut3, cut4,startdate, enddate, lags);

EPSt = EPSIV';%transpose of reduced form errors for which we have an instrument available

sigmahatIV=(1/(length(EPSIV)-k))*(EPSIV'*EPSIV);

