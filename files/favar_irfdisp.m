function [favar]=favar_irfdisp(favar,IRFperiods,endo,IRFt,strctident,pref)

% we arranged everything before including re-transformation
    % pick the relevant shocks (plotXshock) and we are ready to plot
    favar_irf_estimates=favar.IRF.favar_irf_estimates(:,favar.IRF.plotXshock_index);
    
    % plot the IRFs of the factors
    if favar.IRF.plot==1
    % one window for each shock, as we possibly plot a lot of variables in X  
    for px=1:favar.IRF.npltXshck
    irf_favar=figure;
    % shock label
           if IRFt==1||IRFt==2||IRFt==3
            printlabels=endo{favar.IRF.plotXshock_index(1,px),1};
            elseif IRFt==4||IRFt==5||IRFt==6
            printlabels=strctident.signreslabels{favar.IRF.plotXshock_index(1,px)};
           end
    set(irf_favar,'name',['approximate impulse response functions (FAVAR) to shock ',printlabels]);
    
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
        % title of subplot is variable name
        title(favar.informationvariablestrings{1,favar.plotX_index(count)},'FontWeight','normal','interpreter','latex');
    end

    % top supertitle
    ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title(['Shock: ',printlabels],'FontSize',11,'FontName','Times New Roman','FontWeight','normal','interpreter','latex');
    end
    end

    %% save in excel
    if pref.results==1
    favar_excelrecord4
    end