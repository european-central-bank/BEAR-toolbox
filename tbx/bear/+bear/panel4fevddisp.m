function []=panel4fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref)

if pref.plot
    % plot the figure
    fevd=figure('Tag','BEARresults');
    set(fevd,'Color',[0.9 0.9 0.9]);
    set(fevd,'name','forecast error variance decomposition');
    % initiate the count
    count=0;
    % loop over units
    for ii=1:N
        % loop over endogenous variables
        for jj=1:n
            % loop over shocks
            for kk=1:n
                % increment count
                count=count+1;
                % then plot
                subplot(N*n,n,count)
                temp=fevd_estimates{jj,kk,ii};
                hold on
                Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
                Ypatch=[temp(1,:) fliplr(temp(3,:))];
                FEVDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
                set(FEVDpatch,'facealpha',0.5);
                set(FEVDpatch,'edgecolor','none');
                plot(temp(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
                hold off
                set(gca,'XLim',[1 IRFperiods],'YLim',[0 1],'FontName','Times New Roman');
                % top labels
                if jj==1
                    title([Units{ii,1} '\_' endo{kk,1}],'FontWeight','normal');
                end
                % side labels
                if kk==1
                    ylabel([Units{ii,1} '\_' endo{jj,1}],'FontWeight','normal');
                end
            end
        end
    end
    % top supertitle
    ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title('Contribution of shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
    % side supertitle
    ylabel('Variance of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
    set(get(ax,'Ylabel'),'Visible','on');
end



% save on Excel
% create the cell that will be saved on excel
fevdcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},IRFperiods+3,1);
horzspace=repmat({''},2,5*n);
% loop over units
for ii=1:N
    % loop over endogenous variables
    for jj=1:n
        % initiate the cell of results
        endocell={};
        % loop over shocks
        for kk=1:n
            % create a header
            header=[{['part of ' Units{ii,1} '_' endo{jj,1} ' fluctuation due to ' Units{ii,1} '_' endo{kk,1} ' shocks']} {''} {''} {''};{''} {''} {''} {''};{''} {'lower bound'} {'median'} {'upper bound'}];
            % complete the cell
            tempcell=[[header;num2cell((1:IRFperiods)') num2cell((fevd_estimates{jj,kk,ii})')] vertspace];
            % concatenate to the previous parts of unitcell
            endocell=[endocell tempcell];
        end
        % concatenate to the previous parts of irfcell
        fevdcell=[fevdcell;horzspace;endocell];
    end
    fevdcell=[fevdcell;horzspace];
end
% trim
fevdcell=fevdcell(3:end-2,1:end-1);
% write in excel
if pref.results==1
    bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),fevdcell,'FEVD','B2');
end