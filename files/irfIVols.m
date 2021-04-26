function [beta_draws,sigma_draws,IV_draws,C_draws,D,storage1,storage2,D1ols]=irfIVols(betahat,n,m,p,k,T,names,startdate,enddate,X,Y,endo,data_endo,data_exo,const,pref,strctident,IRFt,IRFperiods,It,Bu)


% inputs:  - matrix 'betahat': OLS estimate for beta
%          - matrix 'sigmahat': OLS estimate for sigma
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - cell 'signrestable': table recording the sign restriction input from the user
%          - cell 'signresperiods': table containing the periods corresponding to each restriction
%          - string 'ShockwithInstrument' Name of the shock where the instrument belongs to
% outputs: - cell 'struct_irf_record': record of the draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
%          - matrix 'hd_record': record of historical decompositions
%          - matrix 'ETA_record': record of structural Shocks
%          - vector 'IVcorrelation': vector of correlation with proxy proxy
%          - vector 'PofIVcorrelation': corresponding P-value

%% Phase 1:% %% IV F-Test
% Load IV and make it comparable with the reduced form errors
[~,IVcut,EPSt,~,~,~,IV,txt,OverlapIVinY,cut1,cut2,cut3,cut4]=...
    loadIV(betahat,k,n,Y,X,T,p,names,startdate,enddate,strctident);

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
table_validitytest_values  = [Betas_test_unc;  signif_test_unc;  length(IVcut)*ones(1,n); F_stat_test_unc; Rsquared_test_unc ];
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

% print proxy var statistics in the command window and in the results file 
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
%empty line
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fclose(fid);

%% Preliminiaries for sign restrictions
Acc=It-Bu;  %Minimum accepted draws for the rotation matrix

%% Storage cells and other preliminiaries for the bootstrap part
endo_artificial = zeros(T+p,n); %initialize artifical data matrix
%preliminaries for IV block bootstrap
BlockSize = p; %this can be made frequency specific %only used for bootstraptype2
nBlock = ceil((T)/BlockSize); %only used for bootstraptype2
startofcommonsample= find(OverlapIVinY==1, 1, 'first');
endofcommonsample= find(OverlapIVinY==1, 1, 'last');
%EPShatcut = EPS(OverlapIVinY,:);
beta_draws = nan(k*n,Acc*10); 
sigma_draws=nan(n^2,Acc*10);
IV_draws=nan(n,Acc*10);
C_draws=nan(n^2,Acc*10);
beta = betahat;
B=reshape(beta,k,n);

%%%%while AA<=BB with BB=1000;
%%%%%%%%%%%%%%%%%%%%Bootstrap to approximate distribution of reduced form and IV coefficients%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hbar=parfor_progressbar(Acc*10,'Progress of IV draws.');
for AA=1:Acc*10 %parfor loop possible here? %%%% are 100000 draws necessary? parfor AA=1:Acc*100
% % %     stationary=0; 
% % % while stationary==0
        %%Get reduced form coefficients and IV column
        %% STEP 1: generate the artificial data
        if strctident.bootstraptype==1
            % Initialize wild bootstrap by drawing residuals and flipping the sign at
            % random get reduced form residuals
            EPS  = Y-X*B;
            rotationvector = 1-2*(rand(T,1)>0.5); %the rotation vector is of the same size as EPS. We need to determine where EPS starts in terms of IV and where it ends
            EPSrotate = EPS.*(rotationvector*ones(1,n));
            %create IV specific rotation vector that is 1 if the samples dont
            %overlapp and the EPS rotation vector otherwhise
            %         IVrotationvector = rotationvector(OverlapIVinY);
            %         IVrotate = IV.*IVrotationvector;
            
            IVrotationvector = ones(length(IV),1);
            for kk=startofcommonsample:(endofcommonsample-startofcommonsample)
                if OverlapIVinY(kk,1)==1
                    IVrotationvector(kk,1) = rotationvector(kk,1);
                else
                    IVrotationvector(kk,1) = 1;
                end
            end
            IVrotate = IV.*IVrotationvector;
            
        else
            %%Moving block bootstrap bootstrap
            EPS  = Y-X*B;
            IVblocks = zeros(BlockSize,size(IV,2),length(IV)-BlockSize+1); %create moving blocks for the instrument
            for yy = 1:length(IV)-BlockSize+1
                IVblocks(:,:,yy) = IV(yy:BlockSize+yy-1,:);
            end
            
            EPSblocks = zeros(BlockSize,n,T-BlockSize+1); %create moving blocks for the reduced form errors
            for yy = 1:T-BlockSize+1
                EPSblocks(:,:,yy) = EPS(yy:BlockSize+yy-1,:);
            end
            
            %the first block that can be accomodated by the instrument (i.e. where reduced form errors and instrument overlap
            %is given by EPSblocks(:,:,startofcommonsaple);
            
            %the last block of reduced form errors that can be accomodated by
            %the instrument is EPSblocks(:,:,endofcommonsample-BlockSize);
            
            
            %preliminaries for centering of the bootstrapped VAR errors
            centering = zeros(BlockSize,n);
            for yy = 1:BlockSize
                centering(yy,:) = mean(EPS(yy:T-BlockSize+yy,:,1),1); %running mean
            end
            
            centering = repmat(centering,[nBlock,1]);
            centering = centering(1:T,:);
            
            %center the bootstrapped proxy variables
            IVcentering = zeros(BlockSize,size(IV,2));
            for yy = 1:BlockSize %moving average of the instrument
                subIV = IV(yy:size(IV,1)-BlockSize+yy,:);
                IVcentering(yy,:) = mean(subIV((subIV(:,1) ~= 0),1),1); %running mean
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
            
            if blocks_end > 0 %if we can resample a block from the blocks that are not accomodated by the instrument do so
                pickblock_end = randi([endofcommonsample-BlockSize+2 T-BlockSize+1],blocks_end,1);
                howmanyblock = length((nBlock-blocks_end) : nBlock) ;
                if howmanyblock > length(pickblock_end)
                pickblock((nBlock-blocks_end)+1 : nBlock)=pickblock_end(1:blocks_end);
                else
                pickblock((nBlock-blocks_end) : nBlock)=pickblock_end(1:blocks_end);
                end 
            end
            
            EPSrotate = zeros(nBlock*BlockSize,n);
            IVrotate = zeros(nBlock*BlockSize,size(IV,2));
            for yy = 1:nBlock
                EPSrotate(1+BlockSize*(yy-1):BlockSize*yy,:) = EPSblocks(:,:,pickblock(yy,1));
                IVrotate(1+BlockSize*(yy-1):BlockSize*yy,:) = IVblocks(:,:,pickblockIV(yy,1));
            end
            
            EPSrotate = EPSrotate(1:T,:); %drop last pseudo observations
            IVrotate = IVrotate(1:T,:); %drop last pseudo observations
%             IVrotate = IVrotate(1:length(IV),:);
            IVrotate = IVrotate(OverlapIVinY,:); %drop observations where instrument is not available
            %EPScutrotate = EPSrotate(OverlapIVinY,:);
            %center the bootstrapped residuals and proxies by subtracting
            %the mean
            EPSrotate = EPSrotate - centering;
            for yy = 1:size(IVrotate,2)
                IVrotate((IVrotate(:,yy)~=0),yy) = IVrotate((IVrotate(:,yy)~=0),yy) - IVcentering((IVrotate(:,yy)~=0),yy);
            end
            
        end
        
        %% STEP 2: Generate artificial data
        [endo_artificial_gen]=gen_fake_data(endo_artificial,data_endo,B,EPSrotate,const,p,n,T);
        
        %% STEP 3: estimate reduced form VAR on artificial data.
        [~,betadraw,sigmadraw,Xdraw,~,Ydraw]=olsvar(endo_artificial_gen,data_exo,const,p);
% % %         if IRFt==5
% % %         stationary=1;
% % %         elseif IRFt==6
% % %         [stationary]=checkstable(betadraw,n,p,k); %switches stationary to 0, if the draw is not stationary
% % %         end
        if IRFt==5
        [D,D1ols]=irfiv_ols_for_bootstrap_GK(txt,names,IVrotate,betadraw,n,Xdraw,Ydraw,k,p,enddate,startdate,cut1,cut2,cut3,cut4);
        % Step 5: Calculate impulse responses and store them
        [~,ortirfmatrix]=irfsim(betadraw,D,n,m,p,k,IRFperiods);
       for jj=1:IRFperiods
       storage1{AA,1}(:,:,jj)=ortirfmatrix(:,:,jj);
       end
       storage2{AA,1}=D; 
%        beta_gibbs(:,AA)=betadraw;
%        sigma_gibbs(:,AA)=vec(sigmadraw);
        elseif IRFt==6
        %% Step 4: Identifity the proxy VAR equation
        [D,D1ols,q,C]=irfiv_ols_for_bootstrap_GK(txt,names,IVrotate,betadraw,n,Xdraw,Ydraw,k,p,enddate,startdate,cut1,cut2,cut3,cut4);
        %save draws
        beta_draws(:,AA)=betadraw;
        sigma_draws(:,AA)=vec(sigmadraw);
        %D_draws(:,AA)=vec(D);
        IV_draws(:,AA)=q/norm(q);
        C_draws(:,AA)=vec(C);
        %IVrotate_draws(:,AA)=IVrotate;
        end
%%%AA = AA+1 ;
hbar.iterate(1); % update progress by one iteration 
end
close(hbar);   %close progress bar


