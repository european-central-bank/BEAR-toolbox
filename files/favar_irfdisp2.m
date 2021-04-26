function []=favar_irfdisp2(n,T,decimaldates1,stringdates1,endo,IRFperiods,IRFt,pref,strctident,favar)



% function []=irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,datapath)
% plots the results for the impulse response functions
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs
%          - vector 'D_estimates': point estimate (median) of the structural matrix D, in vectorised form
%          - vector 'gamma_estimates': point estimate (median) of the structural disturbance variance-covariance matrix gamma, in vectorised form
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none

%% Favar preliminaries
npltX=favar.npltX;
npltXshck=favar.IRF.npltXshck;
% we arranged everything before including re-transformation
% pick the relevant shocks (plotXshock) and we are ready to plot
favar_irf_estimates_allt=favar.IRF.favar_irf_estimates_allt(:,favar.IRF.plotXshock_index);

% convert results into interpretable format
plot_estimates=cell(npltX,npltXshck);
for ii=1:npltX
    for jj=1:npltXshck
        for kk=1:IRFperiods
            for tt=1:T
                plot_estimates{ii,jj}(tt,kk)=favar_irf_estimates_allt{ii,jj}(2,kk,tt);
            end
        end
    end
end
plotX = repmat(decimaldates1,1,IRFperiods);
plotY = repmat(1:IRFperiods,T,1);
plot_estimates=plot_estimates';

if pref.plot
    %% create figure for IRFs
    % one window for each shock, as we possbily plot a lot of variables in X
    for px=1:npltXshck
        irf_favar=figure;
        % shock label
        if IRFt==1||IRFt==2||IRFt==3
            printlabels=endo{favar.IRF.plotXshock_index(1,px),1};
        elseif IRFt==4||IRFt==5||IRFt==6
            printlabels=strctident.signreslabels{strctident.signreslabels_shocksindex(px,1)};
        end
        set(irf_favar,'name',['approximate impulse response functions (FAVAR) over all sample periods to shock ',printlabels,]);
        %set(irf_favar,'Color',[0.9 0.9 0.9]);
        numcol=ceil(sqrt(npltX)); % rounded square root of npltX, make the plot quadratic
        numrow=ceil(npltX/numcol); % and the number of rows we need
        %         startIRF=(px*npltX)-npltX+1;
        %         stopIRF=px*npltX;
        count=0;
        for ii=1:npltX
            count=count+1;
            subplot(numrow,numcol,count);
            temp=surf(plotX,plotY,plot_estimates{px,ii});
            set(gca,'Ydir','reverse');
            set(gca,'XLim',[decimaldates1(1,1) decimaldates1(T,1)],'YLim',[1 IRFperiods],'FontName','Times New Roman');
            set(temp,'edgecolor',[0.15 0.15 0.15],'EdgeAlpha',0.5);
            % title of subplot is variable name
            title(favar.informationvariablestrings{1,favar.plotX_index(count)},'FontWeight','normal','interpreter','latex');
        end
        % top supertitle
        ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
        set(get(ax,'Title'),'Visible','on')
        title(['Shock: ',printlabels],'FontSize',11,'FontName','Times New Roman','FontWeight','normal','interpreter','latex');
    end
end % pref.plot

%% save in excel

% save on Excel
if pref.results==1
    % compute the cell for the time varying VAR coefficients
    % initiate the cell that will be saved on excel
    IRFcell={};
    % then loop over endogenous
    for ii=1:npltX
        varcell={};
        % loop over shocks
        for jj=1:npltXshck
            % shock label
            if IRFt==1||IRFt==2||IRFt==3
                printlabels=endo{favar.IRF.plotXshock_index(1,jj),1};
            elseif IRFt==4||IRFt==5||IRFt==6
                printlabels=strctident.signreslabels{strctident.signreslabels_shocksindex(jj,1)};
            end
            % create temporary cell
            temp={};
            temp=[{''} {''} {'Periods'} stringdates1' {''} {''} {''};repmat({''},IRFperiods+4,T+6)];
            temp{3,1}='response of:';
            temp{3,2}=favar.informationvariablestrings{1,favar.plotX_index(ii)};
            temp{4,1}='to shocks in:';
            temp{4,2}=printlabels;
            % loop over IRF periods
            for kk=1:IRFperiods
                temp{2+kk,3}=kk;
                % loop over sample periods
                for tt=1:T
                    temp{2+kk,3+tt}=favar_irf_estimates_allt{ii,jj}(2,kk,tt);
                end
            end
            varcell=[varcell temp];
        end
        IRFcell=[IRFcell;varcell];
    end
    
    % write in excel
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],IRFcell,'favar_IRF time variation','B2');
end