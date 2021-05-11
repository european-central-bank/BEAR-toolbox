function [D, gamma, beginInstrument,EndInstrument, IV]=irfiv_ols(names, betahat,sigmahat,m,n,X,Y,k,p,enddate,startdate,endo,IRFperiods, pref)
%% Copyright Ben Schumann
% function [D, gamma]=irfiv_ols(names, betahat,sigmahat, n,X,Y,k,p,enddate,startdate)
% instrumental variable identification in an OLS setting
% inputs:  - matrix 'betahat': vec(OLS estimates of the reduced form)
%          - matrix 'sigmahat': vec(OLS estimates of sigma)
%          - matrix 'X': Independend Variable
%          - matrix 'Y': Dependend Variable
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the VAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the VAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of observations
%          - string  'stardate': VAR startdate
%          - string  'enddate': VAR enddate
%          - Scalar   'Bootstrap': Indicating if the function is used in a
%          bootstrap procedure or not
% outputs: - matrix 'D': record of the accepted draws for the structural matrix D
%          - matrix 'gamma': record of the draws for the structural disturbances variance-covariance matrix gamma

% Load IV and make it comparable with the reduced form errors
[IV txt]=xlsread('data.xlsx','IV');

namesIV = txt(1,2:end);
datesIV = txt(2:end,1);
datesEndo = names(2:end,1); 
startdateEndo = find(strcmp(startdate,datesEndo));
datesEndo = datesEndo(startdateEndo+p:end,1); %%cut lags from Endo dates
namesEndo = endo';
% IndexIV = find(strcmp(namesIV, Instrument));


%% check for NAN and delete NAN
 IV = IV(~isnan(IV));

%% Step 1: Find startdate and enddate of Y

startlocationIV=find(strcmp(datesIV,startdate));
endlocationIV=find(strcmp(datesIV,enddate));
%check if IV startdate coincides with sample startdate
if isempty(startlocationIV)
    startlocationIV=datesIV(1);
end

%check if IV enddate coincides with sample enddate
if isempty(endlocationIV)
    endlocationIV=datesIV(end);
else 
    endlocationIV = enddatearray;
end 
Index = find(strcmp(endlocationIV,datesIV));
IV = IV(1:Index);

%find spot where IV and Endogenous variables coincide
beginInstrument=find(strcmp(startlocationIV,datesEndo));
EndInstrument  =find(strcmp(endlocationIV,datesEndo));




%% Preparation for first stage regression
variables = n;
parameters= k;

%get reduced form residuals
beta = betahat;
B    = reshape(beta,parameters,variables);
EPS  = Y-X*B;
%Cut EPS or IV such that it corresponds to the IV period
EPSIV = EPS(beginInstrument:EndInstrument,:);
EPSt = EPSIV';


%%  Check strength of instrument
F_stat_test_unc   = NaN*ones(1,n);
signif_test_unc   = NaN*ones(1,n);
Betas_test_unc    = NaN*ones(1,n);
Rsquared_test_unc = NaN*ones(1,n);

for i = 1:n
   yyy      = EPSt(i,:)'; %%get residuals
   xxx_rest = ones(size(EPSt,2),1); %%vector of constants
   xxx      = [ones(size(EPSt,2),1), IV]; %%constants plus instrument

   % restricted model
   coeff_rest = (xxx_rest'*xxx_rest)^(-1)*xxx_rest'*yyy;
   resid_rest = yyy - xxx_rest*coeff_rest;
   RSS_rest   = resid_rest'*resid_rest;

   % unrestricted model
   coeff = (xxx'*xxx)^(-1)*xxx'*yyy;
   resid = yyy - xxx*coeff;
   RSS   = resid'*resid;

   % compute statistic
   F_stat   = (RSS_rest-RSS)*(size(yyy,1)-size(xxx,2))/(RSS*(size(xxx,2)-size(xxx_rest,2)));
   F_pvalue = 1-fcdf(F_stat,size(xxx,2)-size(xxx_rest,2),size(yyy,1)-size(xxx,2));

   F_stat_test_unc(i) = F_stat;
   significance = 3*(F_pvalue < 0.01);
   significance = significance + 2*(F_pvalue < 0.05 & F_pvalue > 0.01);
   significance = significance + 1*(F_pvalue < 0.1 & F_pvalue > 0.05);
   signif_test_unc(i) = significance;
        
   % regression statistics
   coeff  = (xxx'*xxx)^(-1)*xxx'*yyy;        
   fitted = xxx*coeff;
   resid  = yyy - fitted;
   yyy_demean           = yyy - mean(yyy);
   Rsquared_test_unc(i) = 1 - resid'*resid/(yyy_demean'*yyy_demean);
        
   Betas_test_unc(i) = coeff(2);
end   


%% Print F Statistic



table_validitytest_rows = char('coefficient', 'significance level', 'number of obs', 'F statistic', 'R squared');
table_validitytest_rows = cellstr(table_validitytest_rows); 
table_validitytest_values  = [Betas_test_unc;  signif_test_unc;  length(IV)*ones(1,n); F_stat_test_unc; Rsquared_test_unc ];
table_validitytest_columns = cellstr(endo)';

table = array2table(table_validitytest_values); 
for kk=1:length(table_validitytest_columns)
    table.Properties.VariableNames(kk) = table_validitytest_columns(1,kk);
end 
table_rows = cell2table(table_validitytest_rows);
table=[table_rows,table];

for kk=1
    table.Properties.VariableNames(kk) = cellstr(char('Validitytest'));
end

F_test_name=strcat(pref.results_sub,'_Proxy_VAR_F_Test');
filelocation=[pref.datapath '\results\', F_test_name];
fid=fopen(filelocation,'wt');

fprintf('%s\n','');
fprintf(fid,'%s\n','');

fprintf('%s\n','');
fprintf(fid,'%s\n','');

fprintf('F-test for the validity of the instrument')
fprintf('%s\n','');
coeffheader=fprintf('%25s %15s %15s %15s %15s\n','','coefficient','significance','number of obs','F statistic');
coeffheader=fprintf(fid,'%25s %15s %15s %15s %15s\n','','coefficient','significance','number of obs','F statistic');

fprintf('%s\n','');
fprintf(fid,'%s\n','');

% handle the endogenous
   for jj=1:n
      values=[Betas_test_unc(1,jj);  signif_test_unc(1,jj);  length(IV); F_stat_test_unc(1,jj)];
      fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1}),values);
      fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1}),values);
   end
%% Imposing the covariance restrictions 
E_1 = EPSIV'*IV/length(IV);
E11 = E_1(1,:);
E21 = E_1(2:end,:);
Mu = E21*E11^(-1); %relative impulse vector
%% normalize to a one standard deviation shock
sigmahatIV=(1/(length(EPSIV)-k))*(EPSIV'*EPSIV); 

%get the gamma vector
%partition the reduced form VCV
Sigma11 = sigmahatIV(1,1);
Sigma12 = sigmahatIV(1,2:end);
Sigma21 = sigmahatIV(2:end,1);   
Sigma22 = sigmahatIV(2:end,2:end); 

Gamma = Sigma22 + Mu*Sigma11*Mu' - Sigma21*Mu' - Mu*Sigma21';
%get b12 as in Michelle Piffers notes
b12b12t = (Sigma21-Mu*Sigma11)'*Gamma^(-1)*(Sigma21-Mu*Sigma11);
b11b11t = Sigma11 - b12b12t;
b11 = chol(b11b11t); %%this is the scaling vector

%% first stage regression (this results in the same vector as Mu)

%step 2: Regress the first reduced form shock on the instrument
Shock = EPSIV(:,1);
[nobs nvar] = size(IV); 
XX = [IV];
[nobs nvar] = size(XX); 
%get OLS estimate
XpXi = (XX'*XX)\eye(nvar);
betaIV=XpXi*(XX'*Shock);
%get predicted value
IVpred = XX*betaIV;

%% second stage regression
%step 3: Regress the other reduced form shocks on the predicted value
ImpactIRFIV = zeros(n,1);
ImpactIRFIV(1,1) = 1;

for hh=2:n
Shock = EPSIV(:,hh);
[nobs nvar] = size(IVpred); 
IVpredtemp = [IVpred];
[nobs nvar] = size(IVpredtemp); 
IVpIVi = (IVpredtemp'*IVpredtemp)\eye(nvar);
betaIV2=IVpIVi*(IVpredtemp'*Shock);
ImpactIRFIV(hh,1) = betaIV2(1,1); %should be equal to Mu from 2:end
end


% step 5: Create the structural matrix and only fill the first column as
% this is the only one identified
D=eye(n,n);
% Step 6: Replace the first Column in the Cholesky Decomposition by 
%the structural impact matrix computed above
D(1:end,1) = ImpactIRFIV*b11;
gamma=eye(n);
%%another way to retrieve b11 (the scalar that scales the IRF to be a 1sdt Shock) is simply
C=chol(nspd(sigmahatIV),'lower');
b=ImpactIRFIV;
%%Recover the vector q that maps the first column of C into b such that Cq=b;
q = C\b;
%%b11 is the euclidian length of q
b11q = 1/norm(q);

if sum(b11q-b11)> 1.0e-10
    error('Shock is not normalized to 1 std')
end

end
