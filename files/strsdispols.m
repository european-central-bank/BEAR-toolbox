function []=strsdispols(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident)

if IRFt==1||IRFt==2||IRFt==3
    identified=size(endo,1); % fully identified
    labels=endo; % simply use the name of the endogenous variables as labels
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
    labels=strctident.signreslabels_shocks; % signreslabels, only identified shocks
elseif IRFt==5
    identified=1; % one IV shock
    labels{identified,1}=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
end

if pref.plot==1
% create shock figure
strshocks=figure;
set(strshocks,'Color',[0.9 0.9 0.9]);
set(strshocks,'name','structural shocks');
ncolumns=ceil(identified^0.5);
nrows=ceil(identified/ncolumns);
for ii=1:identified
subplot(nrows,ncolumns,ii);
hold on
plot(decimaldates1,strshocks_estimates(ii,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(strshocks_estimates(ii,:));
maxband=max(strshocks_estimates(ii,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin,Ymax],'FontName','Times New Roman');
title(labels{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal','interpreter','latex');
end
end

if pref.results==1
% finally, save in excel
% create the cell that will be saved on excel
horzspace=repmat({''},1,identified);
strshockcell=[{'structural shocks'} horzspace;{''} horzspace;{''} labels';stringdates1 num2cell(strshocks_estimates')];

% write in excel
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],strshockcell,'structshocks','B2');
end