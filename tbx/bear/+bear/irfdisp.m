function []=irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident)

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


% transpose the cell of records (required for the plot function in order to obtain correctly ordered plots)
irf_estimates=irf_estimates';

% number of identified shocks
if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
elseif IRFt==5
    identified=1; % one IV shock
    strctident.signreslabels_shocks{1,1}=strcat('IV Shock (',strctident.Instrument,')'); % and generate the sign res label here
    strctident.signreslabels_shocksindex=1; % first shock
end

count=1;
namecount=1;

if pref.plot==1
% create figure for IRFs
irf=figure('Tag','BEARresults');
set(irf,'Color',[0.9 0.9 0.9]);
%set(irf,'position',[0,0,1920,1080])
   if IRFt==1
   irfname='impulse response functions (no structural identifcation)';
   elseif IRFt==2
   irfname='impulse response functions (structural identification by Cholesky ordering)';
   elseif IRFt==3
   irfname='impulse response functions (structural identification by triangular factorisation)';
   elseif IRFt==4
   irfname=['impulse response functions (structural identification by ',strctident.hbartext_signres,strctident.hbartext_favar_signres,strctident.hbartext_zerores,strctident.hbartext_favar_zerores,strctident.hbartext_magnres,strctident.hbartext_favar_magnres,strctident.hbartext_relmagnres,strctident.hbartext_favar_relmagnres,strctident.hbartext_FEVDres,strctident.hbartext_favar_FEVDres,strctident.hbartext_CorrelInstrumentShock,':::',' restrictions)'];
   irfname=erase(irfname,', :::'); % delete the last , 
   elseif IRFt==5
   irfname=['impulse response functions (structural identification by IV (',strctident.Instrument,'))'];
   elseif IRFt==6
   irfname_temp=[strctident.hbartext_signres,strctident.hbartext_favar_signres,strctident.hbartext_zerores,strctident.hbartext_favar_zerores,strctident.hbartext_magnres,strctident.hbartext_favar_magnres,strctident.hbartext_relmagnres,strctident.hbartext_favar_relmagnres,strctident.hbartext_FEVDres,strctident.hbartext_favar_FEVDres,strctident.hbartext_CorrelInstrumentShock,':::',' restrictions)'];
   irfname_temp=erase(irfname_temp,', :::'); % delete the last , 
   irfname=['impulse response functions (structural identification by IV (',strctident.Instrument,') & ',irfname_temp];
   end
   set(irf,'name',irfname);
   
if IRFt==1||IRFt==2||IRFt==3
for ii=1:n^2
subplot(n,n,ii);
hold on
Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
Ypatch=[irf_estimates{ii}(1,:) fliplr(irf_estimates{ii}(3,:))];
IRFpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(IRFpatch,'facealpha',0.5);
set(IRFpatch,'edgecolor','none');
plot(irf_estimates{ii}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot([1,IRFperiods],[0 0],'k--');
hold off
minband=min(irf_estimates{ii}(1,:));
maxband=max(irf_estimates{ii}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[1 IRFperiods],'YLim',[Ymin Ymax],'FontName','Times New Roman');
% top labels
   if ii<=n
   title(endo{ii,1},'FontWeight','normal','interpreter','none');
   end
% side labels
   if rem((ii-1)/n,1)==0
   ylabel(endo{(ii-1)/n+1,1},'FontWeight','normal','interpreter','none');
   end
end
%% IRFt==4||IRFt==5||IRFt==6
elseif IRFt==4||IRFt==5||IRFt==6
    % subset of irf_estimates and signreslabels that we want to plot
    irf_estimates_shocks=irf_estimates(strctident.signreslabels_shocksindex,:);
    signreslabels_shocks=strctident.signreslabels_shocks;
for jj=1:identified
    for ii=1:n
        count;
        subplot(n,identified,jj+identified*(ii-1));
hold on
Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
Ypatch=[irf_estimates_shocks{jj,ii}(1,:) fliplr(irf_estimates_shocks{jj,ii}(3,:))];
IRFpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(IRFpatch,'facealpha',0.5);
set(IRFpatch,'edgecolor','none');
plot(irf_estimates_shocks{jj,ii}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot([1,IRFperiods],[0 0],'k--');
hold off
minband=min(irf_estimates_shocks{jj,ii}(1,:));
maxband=max(irf_estimates_shocks{jj,ii}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[1 IRFperiods],'YLim',[Ymin Ymax],'FontName','Times New Roman');
% top labels
subplotcolumn=jj+identified*(ii-1);
if subplotcolumn <= identified
title(signreslabels_shocks{subplotcolumn,1},'FontWeight','normal','interpreter','none');
end
if count <= n
   ylabel(endo{namecount,1},'FontWeight','normal','interpreter','none');
   namecount=namecount+1;
end
count = count+1;
end
end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal','interpreter','none');
% side supertitle
ylabel('Response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal','interpreter','none');
set(get(ax,'Ylabel'),'Visible','on')
    set(irf,'PaperPositionMode','Auto')
% % %      PrintName = strcat('IRFs');
% % %      fname = strcat(pref.datapath, '\results\');
% % %      saveas(irf,[fname,PrintName],'epsc')
% % %      saveas(irf,[fname,PrintName],'png')
end


if IRFt==2 || IRFt==3 || IRFt==4 || IRFt==5 || IRFt==6
% then display the results for D and gamma, if a structural decomposition was selected

filelocation=fullfile(pref.results_path, [pref.results_sub '.txt']);
fid=fopen(filelocation,'at');

%print three empty lines
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

%print structural decomposition matrix D
svarinfo1=['D (structural decomposition matrix): posterior estimates'];
fprintf('%s\n',svarinfo1);
fprintf(fid,'%s\n',svarinfo1);

% recover D
D=reshape(D_estimates,n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(bear.vec(D))))));
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

%print two empty lines
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

%print structural disturbances covariance matrix gamma
svarinfo2=['gamma (structural disturbances covariance matrix): posterior estimates'];
fprintf('%s\n',svarinfo2);
fprintf(fid,'%s\n',svarinfo2);

% recover gamma
gamma=reshape(gamma_estimates,n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(bear.vec(gamma))))));
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
end % pref.plot
fclose(fid);
end


% finally, record results in excel
if pref.results==1
% retranspose the cell of records
irf_estimates=irf_estimates';
bear.data.excelrecord4fcn(identified, IRFperiods, IRFt, endo, strctident, irf_estimates, n, pref)
end