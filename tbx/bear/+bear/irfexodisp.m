function irfexodisp(n,m,endo,exo,IRFperiods,exo_irf_estimates,pref,N,Units)
% IRFEXODISP plot impulse response on exogenous variables and write results
% in excel file

arguments
    n
    m
    endo
    exo
    IRFperiods
    exo_irf_estimates
    pref
    N (1,1) double = 1       % for panel var, pass the number of units
    Units (:,1) string = ""  % for panel var, the unit names
end

if pref.plot == 1

    if ~isequal(Units,"")
        Units = Units + "_";
    end

    irf=figure('Tag','BEARresults');
    set(irf,'Color',[0.9 0.9 0.9]);
    set(irf,'name','impulse response functions (exogenous)');
    tl = tiledlayout('flow', 'Parent', irf);
    % top supertitle
    title(tl, 'Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal','interpreter','none')
    % side supertitle
    ylabel(tl, 'Response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal','interpreter','none');

    for nn = 1 : N
        % loop over variables
        for ii=1:n
            % loop over exogenous (for shocks)
            for kk=2:m
                % then plot
                ax = nexttile(tl);

                temp=exo_irf_estimates{ii,kk,nn};
                hold(ax, 'on');
                Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
                Ypatch=[temp(1,:) fliplr(temp(3,:))];
                patch(ax, Xpatch, Ypatch, [0.7 0.78 1], ...
                    'facealpha', 0.5, ...
                    'edgecolor', 'none');
                plot(ax, temp(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
                plot(ax, [1,IRFperiods],[0 0],'k--');
                hold(ax, 'off')
                minband=min(temp(1,:));
                maxband=max(temp(3,:));
                space=maxband-minband;
                Ymin=minband-0.2*space;
                Ymax=maxband+0.2*space;
                set(ax,'XLim',[1 IRFperiods],'YLim',[Ymin Ymax],'FontName','Times New Roman');
                % top labels
                title(ax, Units(nn) + exo{kk-1,1},'FontWeight','normal','interpreter','none');
                % side labels
                ylabel(ax, Units(nn) + endo{ii,1},'FontWeight','normal','interpreter','none');
            end
        end
    end

end

