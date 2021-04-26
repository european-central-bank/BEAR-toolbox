function [favar]=favar_irf(favar,IRFperiods,endo,IRFt,strctident,pref)

% we arranged everything before including transformation
    % pick the relevant shocks (plotXshock)
    favar_irf_estimates=favar.irf_estimates(:,favar.IRF.plotXshock_index);
    
    % save in favar structure, ready to plot
    favar.IRF.favar_irf_estimates=favar_irf_estimates;
    
    % plot the IRFs of the factors
    if favar.IRF.plot==1
    irf_favar=figure;
    set(irf_favar,'name','approximate impulse response functions (FAVAR)');
    numIRFs=favar.npltX*favar.IRF.npltXshck; %total number of IRFs to print
    numcol=5;
    numrow=ceil(numIRFs/numcol); % maximum number of rows
    
    for ii=1:numIRFs
        subplot(numrow,numcol,ii);
        hold on
        Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
        Ypatch=[favar.IRF.favar_irf_estimates{ii}(1,:) fliplr(favar.IRF.favar_irf_estimates{ii}(3,:))];
        IRFpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
        set(IRFpatch,'facealpha',0.5);
        set(IRFpatch,'edgecolor','none');
        plot(favar.IRF.favar_irf_estimates{ii}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
        plot([1,IRFperiods],[0 0],'k--');
        hold off
%         minband=min(favar.IRF.irf_factors_final_plotX{ii}(1,:));
%         maxband=max(favar.IRF.irf_factors_final_plotX{ii}(3,:));
%         space=maxband-minband;
%         Ymin=minband-0.2*space;
%         Ymax=maxband+0.2*space;
        set(gca,'XLim',[1 IRFperiods],'FontName','Times New Roman'); %,'YLim',[Ymin Ymax]
        % top labels
   if ii<=favar.IRF.npltXshck
       if IRFt==1||IRFt==2||IRFt==3
       printlabels=endo{favar.IRF.plotXshock_index(1,ii),1};
       elseif IRFt==4||IRFt==5||IRFt==6
       printlabels=strctident.signreslabels{strctident.signreslabels_shocksindex(ii,1)};
        end
   title(printlabels,'FontWeight','normal','interpreter','latex');
   end
% side labels
   if rem((ii-1)/favar.IRF.npltXshck,1)==0
   ylabel(favar.informationvariablestrings{1,favar.plotX_index((ii-1)/favar.IRF.npltXshck+1)},'FontWeight','normal','interpreter','latex');
   end
    end
    % top supertitle
    ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
    % side supertitle
    ylabel('approximate response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
    set(get(ax,'Ylabel'),'Visible','on')
    end
    
    %% save in excel
    excelrecord4favar