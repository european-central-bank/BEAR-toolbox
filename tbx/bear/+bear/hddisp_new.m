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
    labels=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
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
% a custom colormap
myC=[
    0 0.4470 0.7410;     %blue
    0.8500 0.3250 0.0980; %orange
    0.9290 0.6940 0.1250; %yellow
    0.4940 0.1840 0.5560; %purple
    0.4660 0.6740 0.1880; %green
    0.3010 0.7450 0.9330; %cyan
    0.6350 0.0780 0.1840; %dark red
    0       0       1   ; %other blue
    0       1       0   ; %light green
    1       0       1   ; %pink
    1       1       0   ; %light yellow
    0       1       1   ; %
    1       1       1   ; %
    0.7 0.7 0.7];         %

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
    nContrib=identified;
    for ii=1:contributors
        if ii<=identified
            toplot(ii,1)=1;
        end
        if HDall==1
            if ii>n
                toplot(ii,1)=1;
                nContrib=contributors; %expand the number of contributors in case HDall, where we plot initial values, constant...
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
            hd=figure('Tag','BEARresults');
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
            clear colorm
            
            if length(labels)>14
                colorm=jet;
                % colormap=hsv;
                % colormap=colorcube;
            else
                colorm=myC;
            end
            plothere=1;
            labels2=labels1;
            %             if HDall==1
            for jj=1:nContrib
                if toplot(jj,1)==1
                    contributions(:,plothere)=hd_estimates{jj,ii};
                    plothere=plothere+1;
                end
            end
            
            % sum all contributions if we want to assign them to blocks
            if favar.FAVAR==1
                if favar.blocks==1 && favar.HDplotXblocks==1
                    contributions2=contributions(:,1:identified);
                    % rearrange contributions for blocks
                    % entrys to drop
                    out=[];
                    for kk=1:favar.nbnames
                        out=[out,favar.blocks_index_shocks{kk,1}(2:end,1)];
                    end
                    
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
                        identnonblockshock=[];
                        for oo=1:identified
                            for bb=1:favar.nbnames
                                if contains(labels2(oo,1), favar.bnames(bb,1))==1
                                    labels2(oo)=extractBefore(labels2(oo,1),'.');
                                else
                                    identnonblockshock=[identnonblockshock,oo];
                                end
                            end
                        end
                        labels2(out,:)=[];
                    end
                    
                    for kk=1:size(favar.blocks_index_shocks,1) % rearange contributions blockwise
                        if size(favar.blocks_index_shocks{kk,1},1)~=0
                            contributions3{1,kk}=sum(contributions2(:,favar.blocks_index_shocks{kk,1}),2);
                            contributions2(:,favar.blocks_index_shocks{kk,1}(1,1))=contributions3{1,kk};
                        end
                    end
                    if IRFt==4||IRFt==6 % we plot in this case only the identified shocks, all other is residual, so add the unidentified contributions to "out" vector
                        val=setdiff(favar.variablestrings_exfactors,identnonblockshock);
                        out=[out,val'];
                    end
                    %keep only blocks and Y variables, but add residual
                    contributions2(:,out)=[];
                    if HDall==1
                        contributions2=[contributions2,contributions(:,identified+1)];
                        if const==1 && m>1
                            contributions2=[contributions2,contributions(:,identified+2)];
                            contributions2=[contributions2,contributions(:,identified+3)];
                        elseif const==1 && m==1
                            contributions2=[contributions2,contributions(:,identified+2)];
                        elseif const==0 && m>=1
                            contributions2=[contributions2,contributions(:,identified+3)]; % +3??? or +2?
                        end
                    end
                    % rename
                    contributions=contributions2;
                end
                % before plotting, re-transform
                if favar.transformation==1 || favar.plot_transform==1
                    [contributions,Tobeexplained(ii,:)]=...
                        bear.favar_retransX_contributions2(contributions,Tobeexplained(ii,:),favar.transformationindex_endo(ii),favar.levels);
                end
            end
            
            % distinguish between positive and negative values for plotting reasons
            contribpos=contributions;
            contribpos(contribpos<0)=0;
            contribneg=contributions;
            contribneg(contribneg>0)=0;
            % plot positive values
            hd=bar(decimaldates1,contribpos,'stack', 'FaceColor','flat');
            num=floor((size(colorm,1))/size(contribpos,2));
            for kk=1:size(contribpos,2)
                hd(kk).FaceColor=colorm(kk*num,:);
            end
            hold on
            plothd=gca;
            plothd.ColorOrderIndex=1;
            % plot negative values
            hd=bar(decimaldates1,contribneg,'stack', 'FaceColor','flat');
            for kk=1:size(contribpos,2)
                hd(kk).FaceColor=colorm(kk*num,:);
            end
            
            % plot variable
            plot(decimaldates1,Tobeexplained(ii,:), 'k');
            axis tight
            hold off
            
            % label the endogenous variables
            title(endo{ii,1},'Interpreter','none')
            set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
            box off
            hL=legend(labels2);
            LPosition = [0.47 0.00 0.1 0.1];
            set(hL,'Position', LPosition, 'orientation', 'horizontal','Interpreter','none');
            %annotation('textbox',[0.39 0.92 0.0 0.08],'String',' ','FitBoxToText','on','FontSize',8,'Linestyle','none');
            %set(gcf,'PaperPositionMode','Auto')
            legend boxoff
        end
    end
    
    %% record in excel
    if pref.results==1
        bear.data.excelrecordHDfcn(hd_estimates, T, n, identified, labels1, endo, stringdates1, const, m, contributors, pref)
    end
end


%% FAVAR block decomposition for information variables in X
if favar.HDplot==1
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
        %         if favar.FAVAR==1 && favar.HD.sumShockcontributions==0
        %             labelsfavar1(1:identified)=endo(1:identified);
        %         end
    end
    
    %plot residual anyway
    labelsfavar1{end+1,1} = '*residual*';
    
    toplot=zeros(contributors,1);
    nContrib=identified;
    for ii=1:contributors
        if ii<=identified
            toplot(ii,1)=1;
        end
        if HDall==1
            if ii>n
                toplot(ii,1)=1;
            end
            nContrib=contributors; %expand the number of contributors in case HDall, where we plot initial values, constant...
        end
    end
    
    %     % adjust toplot in this case analogue to to favar.hd_estimates
    %     if favar.HD.sumShockcontributions==1 && favar.blocks==1 && identified<n %the idea is that the columns with the shocks are consistently filled with the favar.blocks_index to use existing routines
    %         for pp=favar.nbnames:-1:1 %start from the end
    %             for uu=1:numel(favar.blocks_index_shocks{pp,1})
    %                 oo=favar.blocks_index_shocks{pp,1}(uu,1);
    %                 yy=favar.blocks_index{pp,1}(uu,1);
    %                 savecolumn=toplot(yy,1);
    %                 toplot(yy,1)=toplot(oo,1);
    %                 toplot(oo,1)=savecolumn;
    %             end
    %         end
    %     end
    
    if pref.plot==1
        for jj=1:favar.npltX %loop over variables specified in plotX
            hdX=figure('Tag','BEARresults');
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
            clear colorm
            
            if length(labelsfavar1)>14
                colorm=jet;
                % colormap=hsv;
                % colormap=colorcube;
            else
                colorm=myC;
            end
            for ii=1:n
                plothere=1;
                for ll=1:nContrib
                    if toplot(ll,1)==1
                        contributions(:,plothere)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
                        sumcontributions(:,plothere,ii)=contributions(:,plothere);
                        plothere=plothere+1;
                    end
                end
            end
            
            % rearrange contributions
            %sum shocks over third dimension of variables
            for ll=1:identified
                contributions2(:,ll)=sum(sumcontributions(:,ll,:),3);
            end
            
            if HDall==1
                % init values
                contributions2(:,identified+1)=sum(sumcontributions(:,identified+1,:),3);
                % if we have a constant and exogenous
                if const==1 && m>1
                    contributions2(:,identified+2)=sum(sumcontributions(:,identified+2,:),3);
                    contributions2(:,identified+3)=sum(sumcontributions(:,identified+3,:),3);
                    % if we have a constant
                elseif const==1 && m<=1
                    contributions2(:,identified+2)=sum(sumcontributions(:,identified+2,:),3);
                elseif const==0 && m>=1
                    contributions2(:,identified+2)=sum(sumcontributions(:,identified+3,:),3); % +3??? or +2?
                end
            end
            labelsfavar=labelsfavar1;
            
            % rearrange contributions for blocks
            if favar.HDplotXblocks==1
                
                % entrys to drop, when we have blocks with more than
                % one factor
                out=[];
                for ii=1:size(favar.blocks_index_shocks,1)
                    %                         out(1,ii)=favar.blocks_index{ii,1}(2:end,1);
                    out=[out,favar.blocks_index_shocks{ii,1}(2:end,1)];
                end
                
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
                    identnonblockshock=[];
                    for oo=1:identified
                        for bb=1:size(favar.blocks_index_shocks,1)
                            if contains(labelsfavar(oo,1), favar.bnames(bb,1))==1
                                % labelsfavar(oo)=extractBefore(labelsfavar(oo,1),'.');
                                labelsfavar(oo)=favar.bnames(bb,1);
                            else
                                identnonblockshock=[identnonblockshock,oo];
                            end
                        end
                    end
                    labelsfavar(out,:)=[];
                end
                
                for ii=1:size(favar.blocks_index_shocks,1) % rearange contributions blockwise, copy the sum of all contributions of this block to the first column of the block, drop the other redundant columns later
                    if size(favar.blocks_index_shocks{ii,1},1)~=0
                        contributions3{1,ii}=sum(contributions2(:,favar.blocks_index_shocks{ii,1}),2);
                        contributions2(:,favar.blocks_index_shocks{ii,1}(1,1))=contributions3{1,ii};
                    end
                end
                
                if IRFt==4||IRFt==6 % we plot in this case only the identified shocks, all other is residual, so add the unidentified contributions to "out" vector
                    val=setdiff(favar.variablestrings_exfactors,identnonblockshock);
                    out=[out,val'];
                end
                %keep only blocks and Y variables, but add residual
                contributions2(:,out)=[];
                
            end
            
            
            % before plotting re-transform, and add residual
            % transform data back according to transformation type
            if favar.transformation==1 || favar.plot_transform==1
                [contributions2,favar.HD.HDTobeexplained_plotX{jj,1}]=...
                    bear.favar_retransX_contributions2(contributions2,favar.HD.HDTobeexplained_plotX{jj,1},transformationindex_plotX(jj,1),favar.levels);
            end
            
            % add residual, this reflects the idiosyncratic component of the information variables in X
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
            hd=bar(decimaldates1,contribpos,'stack', 'FaceColor','flat');
            num=floor((size(colorm,1))/size(contribpos,2));
            for kk=1:size(contribpos,2)
                hd(kk).FaceColor=colorm(kk*num,:);
            end
            hold on
            plothd=gca;
            plothd.ColorOrderIndex=1;
            % plot negative values
            hd=bar(decimaldates1,contribneg,'stack', 'FaceColor','flat');
            for kk=1:size(contribpos,2)
                hd(kk).FaceColor=colorm(kk*num,:);
            end
            hold on
            % plot variable
            plot(decimaldates1,favar.HD.HDTobeexplained_plotX{jj,1}(:,1),'k','LineWidth',0.2);
            axis tight
            hold off
            %end
            
            title(labelsX{jj,1},'Interpreter','none')
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
        bear.data.favar_excelrecordHDfcn(T, favar, contributions2_all, labelsfavar_all, stringdates1, pref)
    end
end
