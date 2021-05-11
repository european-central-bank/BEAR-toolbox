function [favar]=favar_irfols(irf_estimates,favar,const,Bhat,data_exo,n,m,k,lags,EPS,T,data_endo,IRFperiods,endo,IRFt,IRFband,strctident,pref)

% % %        %% this could be modified to bootstrap confidence intervals
% % %         % initiate
% % %         AA=1; % numbers of accepted draws
% % %         BB=500; %Number of draws from bootstrap
% % %         B=Bhat;
% % %         %to use in loop
% % %         %relevant loadings of restricted information variables
% % %         while AA<=BB
% % %         %the rotation vector is of the same size as EPS
% % %         rotationvector = 1-2*(rand(T,1)>0.5);
% % %         EPSrotate = EPS.*(rotationvector*ones(1,n));
% % %
% % %         %% STEP 1.1: initial values for the artificial data
% % %         % Intialize the first p observations with real data
% % %         Temp=[];
% % %         for jj=1:lags
% % %         data_endo_bs(jj,:) = data_endo(jj,:);
% % %         Temp=[data_endo_bs(jj,:) Temp]; %Temp captures all the current and past realizations of the artificial series                                         %that are necesarry to produce the artificially generated data
% % %         end
% % %         % Initialize the artificial series and take care of exogenous variables
% % %         if const==0
% % %             Temp2=Temp;
% % %         elseif const==1
% % %             Temp2=[Temp 1];
% % %         end
% % %
% % %         %% STEP 2.2: generate artificial series
% % %         % From observation p+1 to T(number of observations), compute the artificial data
% % %         for jj=lags+1:T+lags
% % %         for mm=1:n
% % %             % Compute the value for time=jj
% % %             data_endo_bs(jj,mm)=Temp2*B(1:end,mm)+EPSrotate(jj-lags,mm);
% % %         end
% % %         % now update the Temp matrix
% % %         if jj<T+lags
% % %             Temp= [data_endo_bs(jj,:) Temp(1,1:(lags-1)*n)];
% % %             if const==0
% % %                 Temp2=Temp;
% % %             elseif const==1
% % %                 Temp2=[Temp 1];
% % %             end
% % %         end
% % %         end
% % %
% % %         % reestimate the model with bs data
% % %         [~,betahat_bs,sigmahat_bs]=olsvar(data_endo_bs,data_exo,const,lags); %%%%% what if we have data_exo?
% % %         % D_bs
% % %         %D_bs=chol(sigmahat_bs(1:e,1:e))'; % are the indices her necessary?
% % %         D_bs=chol(nspd(sigmahat_bs),'lower');
% % %         %calculating the impulse responses
% % %         [~,ortirfmatrix]=irfsim(betahat_bs,D_bs,n,m,lags,k,IRFperiods);
% % %
% % %         % IRFs
% % %             IRF_bs=[];
% % %             % scale with loading
% % %             for uu=1:favar.nfactorvar %over variables in X that we choose to restrict
% % %                 for ll=1:IRFperiods
% % %                     for qq=1:n %only over selcted shocks  %n % over shocks
% % %                         IRF_bs(uu,qq,ll)=favar.L(uu,:)*ortirfmatrix(:,qq,ll);
% % %                     end
% % %                 end
% % %             end
% % %
% % %         %% Step 6: Store the output
% % %             for jj=1:IRFperiods
% % %                 storage1{AA,1}(:,:,jj)=IRF_bs(:,:,jj);
% % %             end
% % %             storage2{AA,1}=D_bs;
% % %             beta_gibbs(:,AA)=betahat_bs;
% % %             sigma_gibbs(:,AA)=vec(sigmahat_bs);
% % %             AA=AA+1;
% % %         end
% % %         %% Step 7: Reorganize stored output
% % %     % reorganise storage
% % %     % loop over iterations
% % %     for ii=1:BB
% % %     % loop over IRF periods
% % %         for jj=1:IRFperiods
% % %         % loop over variables
% % %             for kk=1:favar.nfactorvar%n
% % %                 % loop over shocks
% % %                 for ll=1:n %n
% % %                     irf_record_bs{kk,ll}(ii,jj)=storage1{ii,1}(kk,ll,jj);
% % %                 end
% % %             end
% % %         end
% % %         D_record(:,ii)=storage2{ii,1}(:);
% % %         gamma_record(:,ii)=vec(eye(n));
% % %     end
% % %     % concatenate over shocks, compute percentiles
% % %     for ll=1:n%n
% % %         irf_record_bs_cat{ll}=[irf_record_bs{:,ll}];
% % %         CI{ll}=prctile(irf_record_bs_cat{ll},[(1-IRFband)/2 IRFband+(1-IRFband)/2]);
% % %         CI_lower{ll}=reshape(CI{ll}(1,:),favar.nfactorvar,IRFperiods);
% % %         CI_upper{ll}=reshape(CI{ll}(2,:),favar.nfactorvar,IRFperiods);
% % %     end
% % %
% % %         for ll=1:n
% % %         CI_low{ll}=CI_lower{1,ll}(favar.plotX_index,:);
% % %         CI_upp{ll}=CI_upper{1,ll}(favar.plotX_index,:);
% % %         end

% in this case load the untransformed IRF estimates
if favar.transformation==1 || favar.plot_transform==1
    irf_estimates=favar.IRF.irf_estimates_nottransformed;
end
%relevant loadings of restricted information variables
L=favar.L(favar.plotX_index,:);

%for each shock save each column separatley
% loop for lower bound, mean, upper bound
for ii=1:3
    % loop over number of factor variables
    for jj=1:n %chosen shocks
        output=[]; %just some temporary output matrix
        for kk=1:n
            output=[output;irf_estimates{kk,jj}(ii,:)];
        end
        irf_estimates_factorshocks{ii,jj}=output;
    end
end
%compute combined shock (all factors, one IRF) for each factor variable
for ii=1:3
    for jj=1:n %shocks, favar.nfactorshocks, favar.nfactorshocks=size(irf_estimates,2);
        irf_estimates_factorshocks_II{ii,jj}=L*irf_estimates_factorshocks{ii,jj}; %in each row one shock
    end
end

%extract IRF (upper bound, mean, lower bound) for each shock, to store it separatley in excel
for ll=1:favar.npltX
    for jj=1:n %shocks, favar.nfactorshocks, favar.nfactorshocks=size(irf_estimates,2);
        output=[];
        for ii=1:3
            output=[output;irf_estimates_factorshocks_II{ii,jj}(ll,:)];
        end
        favar_irf_estimates{ll,jj}=output;
    end
end

% % %         %replace confidence intervals with bs intervals
% % %         for jj=1:favar.npltX
% % %             for ll=1:n
% % %                 favar_irf_estimates{ll,jj}(1,:)=CI_low{ll}(jj,:);
% % %                 favar_irf_estimates{ll,jj}(3,:)=CI_upp{ll}(jj,:);
% % %             end
% % %         end

%check if the variables have been transformed
if favar.transformation==1 || favar.plot_transform==1
    % re-transform favar_irf_record
    favar.IRF.favar_irf_estimates_nottransformed=favar_irf_estimates; % before, save untransformed IRFs
    [favar_irf_estimates]=favar_retransX_irf_estimates(favar_irf_estimates,favar.transformationindex(favar.plotX_index,1),favar.levels);
end

% save in favar structure
favar.IRF.favar_irf_estimates=favar_irf_estimates;
% ready to plot
favar_irf_estimates=favar_irf_estimates(:,favar.IRF.plotXshock_index);

% plot the IRFs of the factors
if favar.IRF.plot==1
    % one window for each shock, as we possbily plot a lot of variables in X
    for px=1:favar.IRF.npltXshck
        irf_favar=figure;
        % shock label
        if IRFt==1||IRFt==2||IRFt==3
            printlabels=endo{favar.IRF.plotXshock_index(1,px),1};
        elseif IRFt==4||IRFt==5||IRFt==6
            printlabels=strctident.signreslabels{strctident.signreslabels_shocksindex(px,1)};
        end
        set(irf_favar,'name',['approximate impulse response functions (FAVAR) for shock ',printlabels]);
        
        numcol=ceil(sqrt(favar.npltX)); % rounded square root of npltX, make the plot quadratic
        numrow=ceil(favar.npltX/numcol); % and the number of rows we need
        startIRF=(px*favar.npltX)-favar.npltX+1;
        stopIRF=px*favar.npltX;
        count=0;
        for ii=startIRF:stopIRF
            count=count+1;
            subplot(numrow,numcol,count);
            hold on
            Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
            Ypatch=[favar_irf_estimates{ii}(1,:) fliplr(favar_irf_estimates{ii}(3,:))];
            IRFpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
            set(IRFpatch,'facealpha',0.5);
            set(IRFpatch,'edgecolor','none');
            plot(favar_irf_estimates{ii}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
            plot([1,IRFperiods],[0 0],'k--');
            hold off
            %         minband=min(favar.IRF.irf_factors_final_plotX{ii}(1,:));
            %         maxband=max(favar.IRF.irf_factors_final_plotX{ii}(3,:));
            %         space=maxband-minband;
            %         Ymin=minband-0.2*space;
            %         Ymax=maxband+0.2*space;
            set(gca,'XLim',[1 IRFperiods],'FontName','Times New Roman'); %,'YLim',[Ymin Ymax]
            %title of subplot is variable name
            title(favar.informationvariablestrings{1,favar.plotX_index(count)},'FontWeight','normal','interpreter','latex');
        end
        
        % top supertitle
        ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
        set(get(ax,'Title'),'Visible','on')
        title(['Shock: ',printlabels],'FontSize',11,'FontName','Times New Roman','FontWeight','normal');
        % %     % side supertitle
        % %     ylabel('approximate response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
        % %     set(get(ax,'Ylabel'),'Visible','on')
    end
end

%% save in excel
if pref.results==1
    favar_excelrecord4
end