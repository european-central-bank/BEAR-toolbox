function [identified]=irf_disp_IV(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,signreslabels,strctident)

%determine number of identified shocks
if IRFt==4||IRFt==6
Index=find(~contains(signreslabels,'shock'));
identified=min(Index)-1;
identified=n-numel(Index);
elseif IRFt==5
identified=1;
signreslabels{1,1} = strcat('Shock identified by IV (',strctident.Instrument,')');
else 
identified = n;
end

count=1;
namecount=1;
irf_estimates = irf_estimates';
hf = figure;
   if IRFt==1
   irfname='impulse response functions (no structural identifcation)';
   elseif IRFt==2
   irfname='impulse response functions (structural identification by Cholesky ordering)';
   elseif IRFt==3
   irfname='impulse response functions (structural identification by triangular factorisation)';
   elseif IRFt==4
   irfname=['impulse response functions (structural identification by ',strctident.hbartext_signres,strctident.hbartext_zerores,strctident.hbartext_magnres,strctident.hbartext_relmagnres,strctident.hbartext_FEVDres,strctident.hbartext_CorrelInstrumentShock,':::',' restrictions)'];
   irfname=erase(irfname,', :::'); % delete the last , 
   elseif IRFt==5
   irfname=['impulse response functions (structural identification by IV ',strctident.Instrument,')'];
   elseif IRFt==6
   irfname_temp=[strctident.hbartext_signres,strctident.hbartext_zerores,strctident.hbartext_magnres,strctident.hbartext_relmagnres,strctident.hbartext_FEVDres,strctident.hbartext_CorrelInstrumentShock,':::',' restrictions)'];
   irfname_temp=erase(irfname_temp,', :::'); % delete the last , 
   irfname=['impulse response functions (structural identification by IV ',strctident.Instrument,' & ',irfname_temp];
   end
   set(hf,'name',irfname);
set(hf,'name',irfname);
set(hf,'Color',[0.9 0.9 0.9]);
%get(0,'ScreenSize');
set(hf,'Units','normalized');
% unitsperplot=0.2*identified*n/6;
% if unitsperplot>1
% set(hf,'position',[0,0,1,1])
% else 
% set(hf,'position',[0,0,0.2*identified,0.2*identified])
% end

%%%%% set(hf,'position',[250,0,1800,1200])
%set(hf, 'Color', [1,1,1]);
%fontsize=ceil(18*(6/n)); %if n=6 fontsize=18;
fontsize=11;

for jj=1:identified
    for ii=1:n
        count;
        subplot(n,identified,jj+identified*(ii-1));
        hold on
Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
Ypatch=[irf_estimates{jj,ii}(1,:) fliplr(irf_estimates{jj,ii}(3,:))];
IRFpatch=patch(Xpatch,Ypatch,[1 0.5 0]);
set(IRFpatch,'facealpha',0.9);
set(IRFpatch,'edgecolor','none');
plot(irf_estimates{jj,ii}(2,:),'Color',[1 0 0],'LineWidth',3);
plot([1,IRFperiods],[0 0],'k--');
hold off
minband=min(irf_estimates{jj,ii}(1,:));
maxband=max(irf_estimates{jj,ii}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[1 IRFperiods],'YLim',[Ymin Ymax],'FontName','Times New Roman','Fontsize',fontsize);
% top labels
subplotcolumn=jj+identified*(ii-1);
if subplotcolumn <= identified
title(signreslabels{subplotcolumn,1},'FontWeight','normal','Interpreter','Latex','Fontsize',fontsize);
end
if count<=n
   ylabel(endo{namecount,1},'FontWeight','normal','Interpreter','none','Fontsize',fontsize);
   namecount=namecount+1;
end
count=count+1;
end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
%%%%% title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
% side supertitle
%%%%% ylabel('Response of:','FontSize',16,'FontName','Times New Roman','FontWeight','normal');
set(get(ax,'Ylabel'),'Visible','on')
    set(gcf,'PaperPositionMode','Auto')
    %fname=strcat(pref.datapath, '\results\');
    %saveas(gcf,[fname,PrintName],'epsc')
    %saveas(gcf,'IRFs','png');
% then display the results for D and gamma, if a structural decomposition was selected

if IRFt==2 || IRFt==3 || IRFt==4 || IRFt==5 || IRFt==6

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'at');

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

svarinfo1=['D (structural decomposition matrix): posterior estimates'];
fprintf('%s\n',svarinfo1);
fprintf(fid,'%s\n',svarinfo1);

% recover D
D=reshape(D_estimates,n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(D))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(D(ii,jj),'% .3f');
      % pad potential missing blanks
      while numel(number)<width
      number=[' ' number];
      end
   number=[number '  '];
   temp=[temp number];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

svarinfo2=['gamma (structural disturbances covariance matrix): posterior estimates'];
fprintf('%s\n',svarinfo2);
fprintf(fid,'%s\n',svarinfo2);

% recover gamma
gamma=reshape(gamma_estimates,n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(gamma))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(gamma(ii,jj),'% .3f');
      % pad potential missing blanks
      while numel(number)<width
      number=[' ' number];
      end
   number=[number '  '];
   temp=[temp number];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end


fclose(fid);
end



% finally, record results in excel
% retranspose the cell of records
irf_estimates=irf_estimates';
excelrecord4
