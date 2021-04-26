function []=strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident)


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
% create structural shocks figure
strshocks=figure;
set(strshocks,'Color',[0.9 0.9 0.9]);
set(strshocks,'name','structural shocks');
ncolumns=ceil(identified^0.5);
nrows=ceil(identified/ncolumns);
for ii=1:identified
subplot(nrows,ncolumns,ii);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[strshocks_estimates{ii,1}(1,:) fliplr(strshocks_estimates{ii,1}(3,:))];
Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(Fpatch,'facealpha',0.6);
set(Fpatch,'edgecolor','none');
plot(decimaldates1,strshocks_estimates{ii,1}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(strshocks_estimates{ii,1}(1,:));
maxband=max(strshocks_estimates{ii,1}(3,:));
space=maxband-minband;
if space==0
    space=0.001;
end 
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin,Ymax],'FontName','Times New Roman');
% create title
title(labels{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal','interpreter','latex');
end

end % pref.plot

% finally, record the results on excel
if pref.results==1
excelrecord9
end


