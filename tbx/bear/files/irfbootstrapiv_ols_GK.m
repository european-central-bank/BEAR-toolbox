function [struct_irf_record, D_record,D,gamma_record,gamma]=irfbootstrapiv_ols_GK(names,betahat,T, m,n,X,Y,k,p,enddate,startdate,endo,IRFperiods,pref,data_endo, data_exo, const,strctident)
% Wild Bootstrap for instrumental variable identification in an OLS setting
% the codes are based on the codes distributed by Ambrogio Cesa-Bianchi in
% his VAR toolbox
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
% outputs: - cell 'struct_irf_record': record of the draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the accepted draws for the structural matrix D
%          - matrix 'gamma_record': record of the draws for the structural disturbances variance-covariance matrix gamma

%% Wild bootstrap including uncertainty about instrument

%% Create the matrices for the loop
% Load IV and make it comparable with the reduced form errors
[EPSIV,IVcut,EPSt,sigmahatIV,B,EPS,df,sigma_hat,inv_sigma_hat,beginInstrument,EndInstrument,IV,txt,OverlapIVinY,cut1,cut2,cut3,cut4]=loadIV(betahat,k,n,Y,X,T,p,names,startdate,enddate,strctident);


%%  Check strength of instrument
F_stat_test_unc   = NaN*ones(1,n);
signif_test_unc   = NaN*ones(1,n);
Betas_test_unc    = NaN*ones(1,n);
Rsquared_test_unc = NaN*ones(1,n);

for i = 1:n
   yyy      = EPSt(i,:)'; %%get residuals
   xxx_rest = ones(size(EPSt,2),1); %%vector of constants
   xxx      = [ones(size(EPSt,2),1), IVcut]; %%constants plus instrument

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

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'at');
%two empty lines
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
%print Proxy VAR statistics title
fprintf('%s\n','Proxy VAR statistics');
fprintf(fid,'%s\n','Proxy VAR statistics');
fprintf('%25s %15s %15s %15s %15s\n','','coefficient','significance','number of obs','F statistic');
fprintf(fid,'%25s %15s %15s %15s %15s\n','','coefficient','significance','number of obs','F statistic');
% handle the endogenous
   for jj=1:n
      values=[Betas_test_unc(1,jj);  signif_test_unc(1,jj);  length(IVcut); F_stat_test_unc(1,jj)];
      fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1}),values);
      fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1}),values);
   end
fclose(fid);

%% Imposing the covariance restrictions 
%E_1 = EPSIV'*IVcut/length(IVcut);
%E11 = E_1(1,:);
%E21 = E_1(2:end,:);
%Mu = E21*E11^(-1); %relative impulse vector
%% normalize to a one standard deviation shock

% %get the gamma vector
% %partition the reduced form VCV
% Sigma11 = sigmahatIV(1,1);
% Sigma12 = sigmahatIV(1,2:end);
% Sigma21 = sigmahatIV(2:end,1);   
% Sigma22 = sigmahatIV(2:end,2:end); 

% Gamma = Sigma22 + Mu*Sigma11*Mu' - Sigma21*Mu' - Mu*Sigma21'; %%%%%this output is not used afterwards, Gamma is not an identity matrix here
% %get b12 as in Michelle Piffers notes
% b12b12t = (Sigma21-Mu*Sigma11)'*Gamma^(-1)*(Sigma21-Mu*Sigma11);
% b11b11t = Sigma11 - b12b12t; 
% b11 = chol(b11b11t); %%this is the scaling vector

%% first stage regression (this results in the same vector as Mu)

%step 2: Regress the first reduced form shock on the instrument
Shock = EPSIV(:,1);
[nobs,~] = size(IVcut); 
XX = [ones(nobs,1) IVcut];
[~,nvar] = size(XX); 
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
[nobs,~] = size(IVpred); 
IVpredtemp = [ones(nobs,1) IVpred];
[~,nvar] = size(IVpredtemp); 
IVpIVi = (IVpredtemp'*IVpredtemp)\eye(nvar);
betaIV2=IVpIVi*(IVpredtemp'*Shock);
ImpactIRFIV(hh,1) = betaIV2(2,1); %should be equal to Mu from 2:end
end


% step 5: Create the structural matrix and only fill the first column as
% this is the only one identified
D=eye(n,n);
% Step 6: Replace the first Column in the Cholesky Decomposition by 
%the structural impact matrix computed above
% D(1:end,1) = ImpactIRFIV*b11;

gamma=eye(n);
%%another way to retrieve b11 (the scalar that scales the IRF to be a 1sdt Shock) is simply
C=chol(nspd(sigmahatIV),'lower');
b=ImpactIRFIV;
%%Recover the vector q that maps the first column of C into b such that Cq=b;
q = C\b;
%%b11 is the euclidian length of q
b11q = 1/norm(q);
if strctident.stdeviation ==1
D(1:end,1) = ImpactIRFIV*b11q;
else
D(1:end,1) = ImpactIRFIV;
end

% if sum(b11q-b11)> 1.0e-8
%     error('Shock is not normalized to 1 std')
% end

%==================================
endo_artificial = zeros(T+p,n);

%% Loop over the number of draws
%==========================================================================

AA = 1; % numbers of accepted draws
%ww = 1; % index for printing on screen
BB = 1000; %Number of draws from bootstrap

%step 1: Create Blocks where IV and EPS coincide
    BlockSize = p; %this can be made frequency specific %only used for bootstraptype2
    nBlock = ceil((T)/BlockSize); %only used for bootstraptype2
    startofcommonsample= find(OverlapIVinY==1, 1, 'first');
    endofcommonsample= find(OverlapIVinY==1, 1, 'last');
    %EPShatcut = EPS(OverlapIVinY,:); unused?

while AA<=BB
    

%% STEP 1: generate the artificial data
% Initialize wild bootstrap by drawing residuals and flipping the sign at
% random get reduced form residuals
if strctident.bootstraptype==1
        rotationvector = 1-2*(rand(T,1)>0.5); %the rotation vector is of the same size as EPS. We need to determine where EPS starts in terms of IV and where it ends
        EPSrotate = EPS.*(rotationvector*ones(1,n));
        %create IV specific rotation vector that is 1 if the samples dont
        %overlapp and the EPS rotation vector otherwhise
        %IVrotationvector = rotationvector(OverlapIVinY);
        %IVrotate = IV.*IVrotationvector;
        IVrotationvector = ones(length(IV),1);
        
        for kk=startofcommonsample:(endofcommonsample-startofcommonsample)
            if OverlapIVinY(kk,1)==1 
            IVrotationvector(kk,1)=rotationvector(kk,1);
            else 
            IVrotationvector(kk,1)=1;
            end
        end 
        IVrotate = IV.*IVrotationvector;

elseif strctident.bootstraptype==2           
        IVblocks = zeros(BlockSize,size(IV,2),length(IV)-BlockSize+1);
        for j = 1:length(IV)-BlockSize+1
            IVblocks(:,:,j) = IV(j:BlockSize+j-1,:);
        end
        
        EPSblocks = zeros(BlockSize,n,T-BlockSize+1);        
        for j = 1:T-BlockSize+1
            EPSblocks(:,:,j) = EPS(j:BlockSize+j-1,:); 
        end
        %the first block that can be accomodated by the instrument (i.e. where reduced form errors and instrument overlap
        %is given by EPSblocks(:,:,startofcommonsaple);
        
        %the last block of reduced form errors that can be accomodated by
        %the instrument is EPSblocks(:,:,endofcommonsample-BlockSize);
               
        
        %center the bootstrapped VAR errors
        centering = zeros(BlockSize,n);
        for j = 1:BlockSize
            centering(j,:)=mean(EPS(j:T-BlockSize+j,:,1),1);
        end
        
        centering = repmat(centering,[nBlock,1]);
        centering = centering(1:T,:);

        %center the bootstrapped proxy variables
        IVcentering = zeros(BlockSize,size(IV,2));
        for j = 1:BlockSize %moving average of the instrument 
            subIV = IV(j:size(IV,1)-BlockSize+j,:);
            IVcentering(j,:) = mean(subIV((subIV(:,1) ~= 0),1),1);
        end
        IVcentering = repmat(IVcentering,[nBlock,1]);
        IVcentering = IVcentering(1:size(IV,1),:);
        
        
        
pickblock = randi([startofcommonsample endofcommonsample-BlockSize+1],nBlock,1);
pickblockIV = pickblock-startofcommonsample+1;
%now check if we can replace some blocks in the beginning of the sample
%with other residuals, that are not accomodated by the instrument
missing_beginning = startofcommonsample;
%missing_end = T-endofcommonsample;

blocks_beginning = floor(missing_beginning/BlockSize); %number of blocks that we can possibly replace in the beginning
blocks_end = floor((T-endofcommonsample)/BlockSize); %number of blocks that we can possibly replace in the end
  
if blocks_beginning > 0 %if the instrument and the sample dont coincide for at least the length of the first block
    pickblock_beginning = randi([1 startofcommonsample],blocks_beginning,1);
    pickblock(1:blocks_beginning,:)=pickblock_beginning(1:blocks_beginning);
end 

if blocks_end > 0
      pickblock_end = randi([endofcommonsample-BlockSize+2 T-BlockSize+1],blocks_end,1);
      pickblock((nBlock-blocks_end)+1 : nBlock)=pickblock_end(1:blocks_end);
end

            EPSrotate = zeros(nBlock*BlockSize,n);
            IVrotate = zeros(nBlock*BlockSize,size(IV,2));
            for j = 1:nBlock
                EPSrotate(1+BlockSize*(j-1):BlockSize*j,:) = EPSblocks(:,:,pickblock(j,1));
                IVrotate(1+BlockSize*(j-1):BlockSize*j,:) = IVblocks(:,:,pickblockIV(j,1));
            end
            EPSrotate = EPSrotate(1:T,:); %drop last pseudo observations
            IVrotate = IVrotate(1:T,:); %drop last pseudo observations
            IVrotate = IVrotate(OverlapIVinY,:); %drop observations where instrument is not available
            %EPScutrotate = EPSrotate(OverlapIVinY,:);

            %center the bootstrapped residuals and proxies by subtracting
            %the mean
            EPSrotate = EPSrotate - centering;
            for j = 1:size(IVrotate,2)
                IVrotate((IVrotate(:,j)~=0),j) = IVrotate((IVrotate(:,j)~=0),j) - IVcentering((IVrotate(:,j)~=0),j);
            end

end
        %% STEP 1.1: initial values for the artificial data
    % Intialize the first p observations with real data
    Temp=[];
    for jj = 1:p
        endo_artificial(jj,:) = data_endo(jj,:);
        Temp = [endo_artificial(jj,:) Temp]; %Temp captures all the current and past realizations of the artificial series                                         %that are necesarry to produce the artificially generated data 
    end
    % Initialize the artificial series and take care of exogenous variables
    if const==0
        Temp2 = Temp;
    elseif const==1
        Temp2 = [Temp 1];
    end
    
    %% STEP 2.2: generate artificial series
    % From observation p+1 to T(number of observations), compute the artificial data
    for jj = p+1:T+p
        for mm = 1:n
            % Compute the value for time=jj
            endo_artificial(jj,mm) = Temp2 * B(1:end,mm) + EPSrotate(jj-p,mm);
        end
        % now update the Temp matrix
        if jj<T+p
            Temp = [endo_artificial(jj,:) Temp(1,1:(p-1)*n)];
            if const==0
                Temp2 = Temp;
            elseif const==1
                Temp2 = [Temp 1];
            end
        end
    end

%% STEP 3: estimate reduced form VAR on artificial data. 
[~,betadraw,sigmadraw,Xdraw,~,Ydraw]=olsvar(endo_artificial,data_exo,const,p);

%% STEP 4: identify the model
[Ddraw]=irfiv_ols_for_bootstrap_GK(txt,beginInstrument,EndInstrument,names,IVrotate,betadraw,sigmadraw,m,n,Xdraw,Ydraw,k,p,enddate,startdate,endo,IRFperiods,pref,cut1,cut2,cut3,cut4,strctident);
%% Step 5: Calculate impulse responses and store them
[~,ortirfmatrix]=irfsim(betadraw,Ddraw,n,m,p,k,IRFperiods);

%% Step 6: Store the output
       for jj=1:IRFperiods
       storage1{AA,1}(:,:,jj)=ortirfmatrix(:,:,jj);
       end
       storage2{AA,1}=Ddraw; 
%        beta_gibbs(:,AA)=betadraw;
%        sigma_gibbs(:,AA)=vec(sigmadraw);
       AA = AA+1 ;
end

