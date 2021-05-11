function [identified] = hddisp_stvol4(hd_estimates, n, exo, T,const,signreslabels, IRFt,pref,decimaldates1, decimaldates2,endo,stringdates1,m,HDall,Y,p,strctident)
%% Preliminaries
%1. Determine how many contributions we are going to calculate
%check if there are 
contributors = n + 1 + 1 + length(exo); %variables + constant + exogenous + initial conditions 
hd_estimates2=cell(contributors+2,n); %shocks+constant+initial values+exogenous+unexplained+to be explained by shocks only

%get number of identified shocks
if IRFt==4 ||IRFt==6 %if the model is identified by sign restrictions or sign restrictions + IV
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
    labels=strctident.signreslabels_shocks; % signreslabels, only identified shocks 
elseif IRFt==5
identified=1;
signreslabels{1,1} = {'Shock identified by external instrument'}; %change sign res labels accordingly
else 
    identified=n; %else the model is fully identified
end

%% drop the confidence bands
    hd_estimates_full = hd_estimates; %rename the estimates that include the lower and upper bound for plotting purposes
    clear hd_estimates; %clear the old version
    hd_estimates = cell(contributors+2,n); %create a new one that only contains the median
    for ii=1:n
        for jj=1:length(hd_estimates_full)
            hd_estimates{jj,ii}(1,:) = hd_estimates_full{jj,ii}(2,:); 
        end
    end

    
    %% plotting phase

%first get the contributions for fully identified models and plot them
if identified==n
if HDall==1 %if we want to plot all contributions
Tobeexplained =Y(2*p+1:end,:)';

%the explained value for each variable is given by Y
% for ii=1:n
%      Sum=0;
%      for kk=1:size(hd_estimates,1)-1
%          Sum = hd_estimates{kk,ii}(1:end)'+ Sum
%      end 
%  Tobeexplained(ii,:)=Sum; 
% end

% loop over all contributors for all endogenous variable
else %if we only want to plot the contributions of the shocks
for ii=1:n
Tobeexplained(ii,:)=hd_estimates{contributors+2,ii}(1:end); 
end
end

else
for ii=1:n
Unexplained(ii,:) =  hd_estimates{contributors+1,ii}(1:end); 
end
if HDall==1 %if we want to plot all contributions
% the actual value for each variable is given by Y
Tobeexplained =Y(2*p+1:end,:)';
else
for ii=1:n
Tobeexplained(ii,:) =  hd_estimates{contributors+2,ii}(1:end); 
end
end 
end

    if HDall==1 
        labels{identified+1,1} = '*initvalues*';
        labels{identified+2,1}='*trend component*';
        if const==1 && m>1
        labels{identified+2,1}='*trend component*';
        labels{identified+3,1}='*exogenous*';
        elseif const==1 && m==1
        labels{identified+2,1}='*trend component*';
        elseif const==0 && m>=1
        labels{identified+2,1}='*exogenous*';
        end
        %labels{end+1,1}='*residual*'; %%%%% do we want residual?
    end

%create labels for the contributions
% if IRFt==2||IRFt==3 %if the VAR is fully identified simply use the name of the endogenous variables as labels
% %     for ii=1:n
% %     labels{ii,1}= endo{ii,1};
% %     end
%     labels=endo;
% 
%     if HDall==1 %if we want to plot the entire decomposition
%         labels{n+1,1} = 'Initial values';
%         labels{n+2,1} = 'trend';
%         if m>1
%         labels{n+3,1} = 'exogenous';
%         end
%     end 
%     
% elseif IRFt==4 ||IRFt==6
% 
%     if HDall==1
%      if m>1
%     labels = cell(identified+3,1);
%      else 
%     labels = cell(identified+2,1);
%     end
%     for ii=1:identified
%     labels{ii,1}= signreslabels{ii,1};
%     end
%     labels{identified+1,1} =  'initial values';
%     labels{identified+2,1} =  'trend';
%     if m>1
%         labels{n+3,1} = 'exogenous';
%     end
%     else
%     labels = cell(identified,1);
%     for ii=1:identified
%     labels{ii,1}= signreslabels{ii,1};
%     end 
%     end
%     
% elseif IRFt==5
%     if HDall==1
%     labels = cell(identified+2,1); %+3
%     labels{identified,1}   =  'Shock identified with IV';
%     labels{identified+1,1} =  'initial values';
%     labels{identified+2,1} =  'constant';
% %     labels{identified+3,1} =  'data';
%     else
%     labels = cell(identified+1,1);
%     labels{identified,1}   =  'Shock identified with IV';
%     labels{identified+1,1}   =  'fluctations'; %%%%%
%     end 
% end

toplot=zeros(contributors,1);

for ii=1:contributors
    
    if ii<=identified
    toplot(ii,1)=1;
    end
    if HDall==1
    if ii>n
        toplot(ii,1)=1;
    end 
    end 
end 

if pref.plot
for ii=1:n
    %create a stacked barchart for each variable
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
% create figure
hd=figure;
set(hd,'position',[250,0,1800,1200])
%set(hd, 'Color', [1,1,1])
set(hd,'name','Historical decomposition');

    clear contributions; 
    clear contribpos;
    clear contribneg;
    colormap=parula;
    
    plothere=1;
    if HDall==1
    for jj=1:contributors
                        if toplot(jj,1)==1
    contributions(:,plothere) = hd_estimates{jj,ii}(1:end);
    contribpos(:,plothere)=hd_estimates{jj,ii}(1:end);
    contribpos(contribpos<0)=0;
    contribneg(:,plothere)=hd_estimates{jj,ii}(1:end);
    contribneg(contribneg>0)=0;
    plothere=plothere+1;
        end 
    end
    else
    for jj=1:identified
                if toplot(jj,1)==1
    contributions(:,jj) = hd_estimates{jj,ii}(1:end);
    contribpos(:,jj)=hd_estimates{jj,ii}(1:end);
    contribpos(contribpos<0)=0;
    contribneg(:,jj)=hd_estimates{jj,ii}(1:end);
    contribneg(contribneg>0)=0;
    plothere=plothere+1;
                end 
    end   
    end
     plothere=1;


if identified==1
hd1=bar(decimaldates1, contributions, 0.8, 'stacked');
hold on
plot(decimaldates1,Tobeexplained(ii,:),'k','LineWidth',0.2);
axis tight
hold off
else
hd=bar(decimaldates1, contribpos,'stack', 'FaceColor','flat');
num=floor((size(colormap,1))/size(contribpos,2));
for kk=1:size(contribpos,2)
    hd(kk).FaceColor=[colormap(kk*num,:)];
end 
hold on
hd=bar(decimaldates1, contribneg,'stack', 'FaceColor','flat');
for kk=1:size(contribpos,2)
    hd(kk).FaceColor=[colormap(kk*num,:)];
end 
%hd=bar(decimaldates1, contribneg, 0.8, 'stacked');
hold on
hd=plot(decimaldates1,Tobeexplained(ii,:), 'k');
axis tight
hold off
end 

% label the endogenous variables
title(endo{ii,1})
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
box off
hL = legend(labels);
LPosition = [0.47 0.00 0.1 0.1];
set(hL,'Position', LPosition, 'orientation', 'horizontal');
dim = [0.39 0.92 0.0 0.08];
str=' ';
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize', 8, 'Linestyle', 'none');
%set(gcf,'PaperPositionMode','Auto')
set(gcf, 'Position', [500, 0, 1000, 1000])
legend boxoff
PrintName = strcat('HD_',endo{ii});
fname = strcat(pref.datapath, '\results\');
saveas(gcf,[fname,PrintName],'epsc')
saveas(gcf,[fname,PrintName],'png')
end 
end
%% record in excel
hd_estimates = hd_estimates'; 
% create the cell that will be saved on excel
hdcell={};
% build preliminary elements: space between the tables
%horzspace=repmat({''},2,3*(identified+1));

%counter
vertspace=repmat({''},T+3,1);


% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
counter=0; %initiate counter
   % loop over shocks (horizontal dimension)
   for jj=1:identified
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
   temp=['contribution of ' labels{jj,1} ' shocks to ' endo{ii,1}];
   hd_ij=[temp {''} ;{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,jj})')];
   tempcell=[tempcell hd_ij vertspace];
   end
counter = identified;
% consider the contribution of initial conditions
temp=['contribution of initial conditions to ' endo{ii,1}];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+1})')];
tempcell=[tempcell hd_ij vertspace];
%hdcell=[hdcell; horzspace; tempcell];
counter = counter+1;
% consider the contribution of the constant
temp=['contribution of trend to ' endo{ii,1}];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+2})')];
tempcell=[tempcell hd_ij vertspace];
counter = counter+1;


if m>1
    % consider the contribution of initial conditions
temp=['contribution of exogenous variables to ' endo{ii,1}];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+3})')];
tempcell=[tempcell hd_ij vertspace];
counter = counter+1;
end 

% unexplained 
if identified < n
temp=['Unexplained part ' endo{ii,1} ' fluctuation (due to missing identification)'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,contributors+1})')];
tempcell=[tempcell hd_ij vertspace];
counter = counter+1;
end 

horzspace=repmat({''},2,3*(counter));

hdcell=[hdcell; horzspace; tempcell];

end
% trim
hdcell=hdcell(1:end,1:end-1);
% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath '\results\' pref.results_sub '.xlsx'],hdcell,'hist decomp','B2');
end

