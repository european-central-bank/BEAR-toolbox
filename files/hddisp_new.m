function hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar)
%computes the historical decomposition for the series (const,exo,betahat,k,n,p,D,m,T,signreslabels,X,Y,data_exo,IRFt,pref,decimaldates1,decimaldates2,endo,stringdates1,HDall,hd_record,HDband,medianmodel,strctident)
%ouput hd_estimates = cell array where columns capture variables, and rows
%the contributions of shocks, exogenous, constant and initial conditions to
%these variables. The second to last rows capture the unexplained part for models
%that are not fully identified, while the last row captures the part of
%the fluctuation that should be explained by the VAR, after accounting for
%exogenous/deterministic components.

%row 1-n = contribution of shock x the movement in variable y hd_estimates(x,y)
%row n+1 = contribution of the constant
%row n+2 = contribution of initial conditions (past shocks)
%row n+3 = unexplained part (for partially identified model)
%row n+4 = part that was left to explain by the structural shocks after accounting for exogenous, constant and initial conditions
%%%%% hard coded for one possible exogenous variable?
%% Preliminaries
%1. Determine how many contributions we are going to calculate
%check if there are
contributors = n + 1 + length(exo) + 1; %variables + constant + exogenous + initial conditions

% number of identified shocks and create labels for the contributions
if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
    labels=endo; % simply use the name of the endogenous variables as labels
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
    labels=strctident.signreslabels_shocks; % signreslabels, only identified shocks
    %labels=strctident.signreslabels; % signreslabels
elseif IRFt==5
    identified=1; % one IV shock
    %labels=endo; % simply use the name of the endogenous variables as labels
    labels{identified,1}=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
end
% if all contributions are plotted add more labels
if HDall==1
    labels{identified+1,1} = '*initvalues*';
    if const==1 && m>1
        labels{identified+2,1}='*constant*';
        labels{identified+3,1}='*exogenous*';
    elseif const==1 && m==1
        labels{identified+2,1}='*constant*';
    elseif const==0 && m>=1
        labels{identified+2,1}='*exogenous*';
    end
    %labels{end+1,1}='*residual*'; %do we want residual in any case?
end

% % for partially identified models
% contributors2=identified+1+length(exo)+1;

% rearrange
hd_estimates_full = hd_estimates; %rename the estimates that include the lower and upper bound for plotting purposes
clear hd_estimates; %clear the old version
for ii=1:n
    for jj=1:length(hd_estimates_full)
        hd_estimates{jj,ii}(1,:)=hd_estimates_full{jj,ii}(2,:);
    end
end

%% plotting phase
if HD==1
    %first get the contributions for fully identified models and plot them
    if identified==n
        if HDall==1 %if we want to plot all contributions
            % the actual value for each variable is given by Y
            Tobeexplained=Y';
            % loop over all contributors for all endogenous variable
        else %if we only want to plot the contributions of the shocks
            for ii=1:n
                Tobeexplained(ii,:)=hd_estimates{contributors+2,ii};
            end
        end
    else % for partially identified models
        for ii=1:n
            Unexplained(ii,:)=hd_estimates{contributors+1,ii};
        end
        if HDall==1 %if we want to plot all contributions
            % the actual value for each variable is given by Y
            Tobeexplained=Y';
        else
            for ii=1:n
                Tobeexplained(ii,:)=hd_estimates{contributors+2,ii};
            end
        end
    end
    
    toplot=zeros(contributors,1);
    for ii=1:contributors
        if ii<=identified
            toplot(ii,1)=1;
        end
        if HDall==1
            if ii>n
                toplot(ii,1)=1;
            end
        end
    end
    
    %create labels for the contributions
    if IRFt==1||IRFt==2||IRFt==3
        labels1=labels;%endo; %simply use the name of the endogenous variables as labels
    elseif IRFt==5
        labels1{identified,1}=labels;%strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
    elseif IRFt==4||IRFt==6
        labels1=labels; %strctident.signreslabels_shocks; % signreslabels
    end
    %     %plot residual anyway
    %     labelsfavar1{end+1,1} = '*residual*';
    
    if pref.plot==1
        for ii=1:n
            hd=figure;
            set(hd,'name',strcat('historical decomposition (',endo{ii,1},')'));
            % clear previous variables
            clear contributions;
            clear contributions2;
            clear contributions3;
            clear contribpos;
            clear contribneg;
            clear out
            clear in
            clear residual
            
            plothere=1;
            labels2=labels1;
            if HDall==1
                for jj=1:contributors
                    if toplot(jj,1)==1
                        contributions(:,plothere)=hd_estimates{jj,ii};
                        plothere=plothere+1;
                    end
                end
                
                % sum all contributions if we want to assign them to blocks
                if favar.FAVAR==1
                    if favar.HD.plotXblocks==1
                        contributions2=contributions(:,1:identified);
                        % rearrange contributions for blocks
                        % entrys to drop
                        for kk=1:favar.nbnames
                            out{kk,:}=favar.blocks_index{kk,1}(2:end,1);
                        end
                        out=cat(1,out{:});
                        
                        % initiate labels
                        if IRFt==1||IRFt==2||IRFt==3
                            labels2=labels1;%endo; %simply use the name of the endogenous variables as labels
                            % label adjustments
                            labels2(out,:)=[];
                            labels2=erase(labels2,'.factor1');
                        elseif IRFt==5
                            labels2{identified,1}=labels1;%strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
                        elseif IRFt==4||IRFt==6
                            labels2=labels1; %atm we assume number of shocks (labels) is equal to the number of blocks
                            % name the sumed shock of a block simply after the block identifier name
                            for oo=1:identified
                                labels2(oo)=extractBefore(labels2(oo,1),'.');
                            end
                            % if we have more than 2 shocks we need to adjust number of labels
                            if numel(favar.blocks_index_shocks)>2
                                for ii=1:favar.nbnames
                                    outlabels{ii,:}=favar.blocks_index_shocks{ii,1}(1,2:end); %%%%case for 1 shock only
                                end
                                labels2(outlabels,:)=[];
                            end
                        end
                        
                        for kk=1:favar.nbnames % rearange contributions blockwise
                            contributions3{1,kk}=sum(contributions2(:,favar.blocks_index{kk,1}),2);
                            contributions2(:,favar.blocks_index{kk,1}(1,1))=contributions3{1,kk};
                        end
                        %keep only blocks and Y variables, but add residual
                        contributions2(:,out)=[];
                        
                        contributions2=[contributions2,contributions(:,identified+1)];
                        if const==1 && m>1
                            contributions2=[contributions2,contributions(:,identified+2)];
                            contributions2=[contributions2,contributions(:,identified+3)];
                        elseif const==1 && m==1
                            contributions2=[contributions2,contributions(:,identified+2)];
                        elseif const==0 && m>=1
                            contributions2=[contributions2,contributions(:,identified+3)]; % +3??? or +2?
                        end
                        
                        % rename
                        contributions=contributions2;
                    end
                    
                end
                
            else
                for jj=1:identified
                    if toplot(jj,1)==1
                        contributions(:,jj)=hd_estimates{jj,ii};
                        plothere=plothere+1;
                    end
                end
                % sum all contributions if we want to assign them to blocks
                if favar.FAVAR==1
                    if favar.HD.plotXblocks==1
                        contributions2=contributions(:,1:identified);
                        % rearrange contributions for blocks
                        labels2=endo; % initiate labels
                        for kk=1:favar.nbnames
                            out{kk,:}=favar.blocks_index{kk,1}(2:end,1); % entrys to drop
                        end
                        out=cat(1,out{:});
                        
                        for kk=1:favar.nbnames % rearange contributions blockwise
                            contributions3{1,kk}=sum(contributions2(:,favar.blocks_index{kk,1}),2);
                            contributions2(:,favar.blocks_index{kk,1}(1,1))=contributions3{1,kk};
                        end
                        %keep only blocks and Y variables
                        contributions2(:,out)=[];
                        % label adjustments
                        labels2(out,:)=[];
                        labels2=erase(labels2,'.factor1');
                                            % rename
                    contributions=contributions2;
                    end

                end
                
            end
            
            if favar.FAVAR==1
                % before plotting, re-transform
                if favar.transformation==1 || favar.plot_transform==1
                    [contributions,Tobeexplained(ii,:)]=...
                        favar_retransX_contributions2(contributions,Tobeexplained(ii,:),favar.transformationindex_endo(ii),favar.levels);
                end
            end
            
            % distinguish between positive and negative values for plotting reasons
            contribpos=contributions;
            contribpos(contribpos<0)=0;
            contribneg=contributions;
            contribneg(contribneg>0)=0;
            % plot positive values
            bar(decimaldates1, contribpos,'stack');
            hold on
            plothd=gca;
            plothd.ColorOrderIndex=1;
            % plot negative values
            bar(decimaldates1, contribneg,'stack');
            hold on
            % plot variable
            plot(decimaldates1,Tobeexplained(ii,:), 'k');
            axis tight
            hold off
            
            % label the endogenous variables
            title(endo{ii,1},'Interpreter','latex')
            set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
            box off
            hL=legend(labels2);
            LPosition = [0.47 0.00 0.1 0.1];
            set(hL,'Position', LPosition, 'orientation', 'horizontal','Interpreter','latex');
            %annotation('textbox',[0.39 0.92 0.0 0.08],'String',' ','FitBoxToText','on','FontSize',8,'Linestyle','none');
            %set(gcf,'PaperPositionMode','Auto')
            legend boxoff
        end
    end
    
    %% record in excel
    if pref.results==1
        excelrecordHD
    end
end


%% FAVAR block decomposition for information variables in X
if favar.HD.plot==1
    % plot X subsample of tranformationindex
    transformationindex_plotX=favar.transformationindex(favar.plotX_index,1);
    
    %first get the contributions for fully identified models and plot them
    if identified==n
        if HDall==1 %if we want to plot all contributions
            % the actual value for each variable is given by Y
            for jj=1:favar.npltX %nblockindex
                favar.HD.HDTobeexplained_plotX{jj,1}=favar.X(lags+1:end,favar.plotX_index(jj,1));
            end
        elseif HDall==0 %if we only want to plot the contributions of the shocks only
            for jj=1:favar.npltX
                %             for ii=1:n
                favar.HD.HDTobeexplained_plotX{jj,1}=favar.X(lags+1:end,favar.plotX_index(jj,1));%favar.HD.hd_estimates{contributors+2,ii,jj}(1:end);
                %             end
            end
        end
    else % how is case this different?
        for jj=1:favar.npltX
            for ii=1:n
                favar.HD.HDUnexplained_plotX{jj,1}(:,ii)=favar.X(lags+1:end,favar.plotX_index(jj,1));%favar.HD.hd_estimates{contributors+1,ii,jj}(1:end);
            end
        end
        if HDall==1
            for jj=1:favar.npltX %nblockindex
                favar.HD.HDTobeexplained_plotX{jj,1}=favar.X(lags+1:end,favar.plotX_index(jj,1));
            end
        elseif HDall==0
            for jj=1:favar.npltX
                %             for ii=1:n
                favar.HD.HDTobeexplained_plotX{jj,1}=favar.X(lags+1:end,favar.plotX_index(jj,1));%favar.HD.hd_estimates{contributors+2,ii,jj}(1:end);
                %             end
            end
        end
    end
    
    %create labels for the contributions
    labelsX=favar.pltX; % plotX labels
    
    %create labels for the contributions
    if IRFt==1||IRFt==2||IRFt==3
        labelsfavar1=labels;%endo; %simply use the name of the endogenous variables as labels
    elseif IRFt==5
        labelsfavar1{identified,1}=labels;%strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
    elseif IRFt==4||IRFt==6
        labelsfavar1=labels; %strctident.signreslabels_shocks; % signreslabels
    end
    % truncate labels if favar.HD.HDallsumblock=1
    if HDall==1 && favar.HD.HDallsumblock==1 %
        labelsfavar1=labelsfavar1(1:identified,1);
    end
    %plot residual anyway
    labelsfavar1{end+1,1} = '*residual*';
    
    
    toplot=zeros(contributors,1);
    for ii=1:contributors
        if ii<=identified
            toplot(ii,1)=1;
        end
        if HDall==1
            if ii>n
                toplot(ii,1)=1;
            end
        end
    end
    
    % adjust toplot in this case analogue to to favar.hd_estimates
    if favar.HD.sumShockcontributions==1 && favar.blocks==1 && identified<n %%and slightly different routine in this case, the idea is that the columns with the shocks are consistently filled with the favar.blocks_index to use existing routines
        for pp=favar.nbnames:-1:1 %start from the end
            for uu=1:numel(favar.blocks_index_shocks{pp,1})
                oo=favar.blocks_index_shocks{pp,1}(uu,1);
                yy=favar.blocks_index{pp,1}(uu,1);
                savecolumn=toplot(yy,1);
                toplot(yy,1)=toplot(oo,1);
                toplot(oo,1)=savecolumn;
            end
        end
    end
    
    
    if pref.plot==1
        for jj=1:favar.npltX %loop over variables specified in plotX
            hdX=figure;
            set(hdX,'name',['approximate historical decomposition of',' ',labelsX{jj}]);
            % clear previous variables
            clear contributions;
            clear contributions2;
            clear contributions3;
            clear contribpos;
            clear contribneg;
            clear out
            clear in
            clear residual
            
            if HDall==1
                for ii=1:n
                    plothere=1;
                    for ll=1:contributors
                        if toplot(ll,1)==1
                            contributions(:,plothere)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
                            sumcontributions(:,plothere,ii)=contributions(:,plothere);
                            plothere=plothere+1;
                        end
                        %sumcontributions(:,ll,ii)=contributions(:,ll:contributors2:end);
                        %sumcontributions(:,ll,ii)=contributions(:,plothere-1); %counter plothere is already preparerd for the next step
                    end
                    % sum all contributions if we want to assign them to blocks
                    if favar.HD.plotXblocks==1
                        contributions2(:,ii)=sum(contributions,2);
                    end
                end
                
                
                % rearrange contributions
                if favar.blocks==0 || favar.HD.plotXblocks==0
                    %sum shocks over third dimension of contributions
                    for ll=1:identified
                        contributions2(:,ll)=sum(sumcontributions(:,:,ll),2);
                    end
                    % init values
                    contributions2(:,identified+1)=sumcontributions(:,identified+1,1);
                    % if we have a constant and exogenous
                    if const==1 && m>1
                        contributions2(:,identified+2)=sumcontributions(:,identified+2,1);
                        contributions2(:,identified+3)=sumcontributions(:,identified+3,1);
                        % if we have a constant
                    elseif const==1 && m<=1
                        contributions2(:,identified+2)=sumcontributions(:,identified+2,1);
                    elseif const==0 && m>=1
                        contributions2(:,identified+2)=sumcontributions(:,identified+3,1); % +3??? or +2?
                    end
                    labelsfavar=labelsfavar1;
                    
                    % rearrange contributions for blocks
                elseif favar.HD.plotXblocks==1
                    
                    % entrys to drop
                    for ii=1:favar.nbnames
                        out{ii,:}=favar.blocks_index{ii,1}(2:end,1);
                    end
                    out=cat(1,out{:});
                    
                    % initiate labels
                    if IRFt==1||IRFt==2||IRFt==3
                        labelsfavar=labelsfavar1;%endo; %simply use the name of the endogenous variables as labels
                        % label adjustments
                        labelsfavar(out,:)=[];
                        labelsfavar=erase(labelsfavar,'.factor1');
                    elseif IRFt==5
                        labelsfavar{identified,1}=labelsfavar1;%strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
                    elseif IRFt==4||IRFt==6
                        labelsfavar=labelsfavar1; %atm we assume number of shocks (labels) is equal to the number of blocks
                        % name the sumed shock of a block simply after the block identifier name
                        for oo=1:identified
                            labelsfavar(oo)=extractBefore(labelsfavar(oo,1),'.');
                        end
                        % if we have more than 2 shocks we need to adjust number of labels
                        if numel(favar.blocks_index_shocks)>2
                            for ii=1:favar.nbnames
                                outlabels{ii,:}=favar.blocks_index_shocks{ii,1}(1,2:end);
                            end
                            labelsfavar(outlabels,:)=[];
                        end
                    end
                    
                    if favar.HD.HDallsumblock==0
                        for ll=1:identified
                            contributions2(:,ll)=sum(sumcontributions(:,:,ll),2);
                        end
                    end
                    
                    for ii=1:favar.nbnames % rearange contributions blockwise
                        contributions3{1,ii}=sum(contributions2(:,favar.blocks_index{ii,1}),2);
                        contributions2(:,favar.blocks_index{ii,1}(1,1))=contributions3{1,ii};
                    end
                    %keep only blocks and Y variables, but add residual
                    contributions2(:,out)=[];
                    
                    if favar.HD.HDallsumblock==0
                        contributions2=[contributions2,sumcontributions(:,identified+1,1)];
                        if const==1 && m>1
                            contributions2=[contributions2,sumcontributions(:,identified+2,1)];
                            contributions2=[contributions2,sumcontributions(:,identified+3,1)];
                        elseif const==1 && m==1
                            contributions2=[contributions2,sumcontributions(:,identified+2,1)];
                        elseif const==0 && m>=1
                            contributions2=[contributions2,sumcontributions(:,identified+3,1)]; % +3??? or +2?
                        end
                    end
                end
                
            elseif HDall==0
                for ii=1:n
                    plothere=1;
                    for ll=1:identified
                        if toplot(ll,1)==1
                            contributions(:,plothere)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
                            sumcontributions(:,plothere,ii)=contributions(:,plothere);
                            plothere=plothere+1;
                        end
                        
                    end
                    if favar.HD.plotXblocks==1
                    contributions2(:,ii)=sum(contributions,2);
                    end
                end
                

                    
                % rearrange contributions
                if favar.blocks==0 || favar.HD.plotXblocks==0
                    %sum shocks over third dimension of contributions
                    for ll=1:identified
                        contributions2(:,ll)=sum(sumcontributions(:,:,ll),2);
                    end
                    labelsfavar=labelsfavar1;
                    % rearrange contributions for blocks
                elseif favar.HD.plotXblocks==1
                    % rearrange contributions for blocks
                    labelsfavar=labelsfavar1; % initiate labels
                    for kk=1:favar.nbnames
                        out{kk,:}=favar.blocks_index{kk,1}(2:end,1); % entrys to drop
                    end
                    out=cat(1,out{:});
                    
                    for ii=1:favar.nbnames % rearange contributions blockwise
                        contributions3{1,ii}=sum(contributions2(:,favar.blocks_index{ii,1}),2);
                        contributions2(:,favar.blocks_index{ii,1}(1,1))=contributions3{1,ii};
                    end
                    %keep only blocks and Y variables
                    contributions2(:,out)=[];
                    % label adjustments
                    labelsfavar(out,:)=[];
                    labelsfavar=erase(labelsfavar,'.factor1');
                end
            end
            
            % before plotting re-transform, and add residual
            % transform data back according to transformation type
            if favar.transformation==1 || favar.plot_transform==1
                [contributions2,favar.HD.HDTobeexplained_plotX{jj,1}]=...
                    favar_retransX_contributions2(contributions2,favar.HD.HDTobeexplained_plotX{jj,1},transformationindex_plotX(jj,1),favar.levels);
            end
            
            % add residual
            residual=favar.HD.HDTobeexplained_plotX{jj,1}-sum(contributions2,2);
            contributions2=[contributions2,residual];
            
            % save them to store them in excel
            contributions2_all{jj,1}=contributions2;
            labelsfavar_all=labelsfavar;
            
            % distinguish between positive and negative values for plotting
            contribpos=contributions2;
            contribpos(contribpos<0)=0;
            contribneg=contributions2;
            contribneg(contribneg>0)=0;
            % plot positive values
            bar(decimaldates1,contribpos,'stack');
            hold on
            plothd=gca;
            plothd.ColorOrderIndex=1;
            % plot negative values
            bar(decimaldates1,contribneg,'stack');
            hold on
            % plot variable
            plot(decimaldates1,favar.HD.HDTobeexplained_plotX{jj,1}(:,1),'k','LineWidth',0.2);
            axis tight
            hold off
            %end
            
            title(labelsX{jj,1},'Interpreter','latex')
            set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
            box off
            hL=legend(labelsfavar);
            LPosition=[0.47 0.00 0.1 0.1];
            set(hL,'Position',LPosition,'orientation','horizontal');
            dim=[0.39 0.92 0.0 0.08];
            annotation('textbox',dim,'String',' ','FitBoxToText','on','FontSize',8,'Linestyle','none');
            %set(gcf,'PaperPositionMode','Auto')
            legend boxoff
        end
    end
    
    %% record in excel
    if pref.results==1
        favar_excelrecordHD
    end
end

