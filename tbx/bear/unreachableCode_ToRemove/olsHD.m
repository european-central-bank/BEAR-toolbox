function [hd_estimates,favar]=olsHD(const,exo,n,m,T,Y,IRFt,pref,decimaldates1,endo,stringdates1,HDall,lags,HD,HDband,hd_record,strctident,favar)
%computes the historical decomposition for the series (const,exo,betahat,k,n,p,D,m,T,signreslabels,X,Y,data_exo,IRFt,pref,decimaldates1,decimaldates2,endo,stringdates1,HDall,hd_record,HDband,medianmodel,strctident)
%ouput hd_estimates = cell array where columns capture variables, and rows
%the contributions of shocks, exogenous, constant and initial conditions to
%these variables. The second to last rows capture the unexplained part for models
%that are not fully identified, while the last row captures the part of
%the fluctuation that should be explained by the VAR, after accounting for
%exogenous/deterministic components. 

%row 1-n = contribution of shock x the movement in variable y hd_estimates(x,y)
%row n+1 = contribution of the constant
%row n+2 = contribution of initial conditions (past shocks)
%row n+3 = unexplained part (for partially identified model)
%row n+4 = part that was left to explain by the structural shocks after accounting for exogenous, constant and initial conditions
%%%%% hard coded for one possible exogenous variable?
%% Preliminaries
%1. Determine how many contributions we are going to calculate
%check if there are 
contributors = n + const + length(exo) + 1; %variables + constant + exogenous + initial conditions
hd_estimates=cell(contributors+2,n); %shocks+constant+initial values+exogenous+unexplained+to be explained by shocks only

% number of identified shocks
if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
elseif IRFt==5
    identified=1; % one IV shock
end

% for partially identified models
contributors2=identified+const+length(exo)+1;

if IRFt==1||IRFt==2||IRFt==3
hd_estimates=hd_record;

elseif IRFt==4 | IRFt==6
    
if strctident.MM==0
% deal with shocks in turn
for ii=1:n
   % loop over variables
   for jj=1:length(hd_record)
      % loop over time periods
      for kk=1:T
      % consider the higher and lower confidence band for the hd
      % lower bound
      hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(1-HDband)/2);
      %mean value
      hd_estimates{jj,ii}(2,kk)=quantile(hd_record{jj,ii}(:,kk),0.5);
      % upper bound
      hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),HDband+(1-HDband)/2);
      end
   end
end

for yy=1:3
%%recalculate the unexplaned part for the upper, lower, and median
HDsum = zeros(T,n); 
 for jj=1:n %loop over variables (columns)
 sumvariable = zeros(1,T);
 for kk=1:T %loop over periods
     sumperiod=0; 
  for ii=1:contributors %loop over contributors (rows)
      sumperiod = sumperiod+hd_estimates{ii,jj}(yy,kk);
  end
  sumvariable(1,kk) = sumperiod; 
 end 
 HDsum(:,jj)=sumvariable(1,:); 
 end
 
 %redetermine the unexplained part because we didnt choose the median
 %model, the pointwise median doesnt need to add up to the data

 unexplained = Y-HDsum(1:end,:); 
for jj=1:n
    hd_estimates{contributors+1,jj}(yy,:)=unexplained(:,jj)';
end
end

%% finally substract the sum of the contribution of the exogenous, constant,initial conditions from Y to get the
%part that was left to be explained by the shocks (for plotting reasons)
 Exosum = zeros(T,n); %
 for jj=1:n %loop over variables (columns)
 sumvariable = zeros(1,T);
 for kk=1:T %loop over periods
     sumperiod=0; 
  for ii=n+1:contributors %loop over contributors (rows)
      sumperiod = sumperiod+hd_estimates{ii,jj}(2,kk); 
  end
  sumvariable(1,kk) = sumperiod; 
 end 
 Exosum(:,jj)=sumvariable(1,:); 
 end 
 
 %% determine the part that was left to be explained by the shocks
%  aux = zeros(1,n);
 tobeexplained = Y - Exosum(1:end,:); 
%  tobeexplained = [aux; tobeexplained];
for jj=1:n
    hd_estimates{contributors+2,jj}(2,:)=tobeexplained(:,jj)';
end 


elseif strctident.MM==1 %Median Model
for ii=1:n
   % loop over variables
   for jj=1:length(hd_record)
      % loop over time periods
      for kk=1:T
      % consider the higher and lower confidence band for the hd
      % lower bound
      hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(1-HDband)/2);
      %medianmodel
      hd_estimates{jj,ii}(2,kk)= hd_record{jj,ii}(medianmodel,kk); %get the best performing model in terms of IRFs
      % upper bound
      hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),HDband+(1-HDband)/2);
      % upper bound
      end
   end
end
end    

% rearrange
hd_estimates_full = hd_estimates; %rename the estimates that include the lower and upper bound for plotting purposes
    clear hd_estimates; %clear the old version
    hd_estimates = cell(contributors+2,n); %create a new one that only contains the median
    for ii=1:n
        for jj=1:length(hd_estimates_full)
            hd_estimates{jj,ii}(1,:)=hd_estimates_full{jj,ii}(2,:); 
        end
    end
end

 
%% FAVAR: scale hd_estimates with loadings
% if favar.pX==1 here every individual part is scaled and then aggregated
% in favar.hd_estimates
%     for jj=1:favar.npltX %do this routine for selected informational variables  %favar.nblockindex: for all factor variables
%         for ii=1:n %for each factor
%             for ll=1:n %for each shock contribution
%                 favar.HD.HDestimates{jj,1}(ii,:,ll)=HDestimates(ii,:,ll)*favar.L(favar.plotX_index(jj,1),ii); % for shocks
%             end
%         favar.HD.HDinitial_estimates{jj,1}(ii,:)=HDinitial_estimates(ii,:)*favar.L(favar.plotX_index(jj,1),ii); % for inital values
%         if const==1
%             favar.HD.HDconstant_estimates{jj,1}(ii,:)=HDconstant_estimates(ii,:)*favar.L(favar.plotX_index(jj,1),ii); % for constant values
%         end
%         if m>1
%             favar.HD.HDexo_estimates{jj,1}(ii,:)=HDexo_estimates(ii,:)*favar.L(favar.plotX_index(jj,1),ii); % for exo values
%         end
%         end
%     end
%     
% 
% % reorganize all for plotting
% for jj=1:favar.npltX %for all factor variables
%         for ii=1:n %for variables
%             for kk=1:T+1 %for periods %is this loop maybe redundant?
%                 for ll=1:n %for shock contributions
%                     favar.HD.hd_estimates2{ll,ii,jj}(1,kk)=favar.HD.HDestimates{jj,1}(ii,kk,ll);%summed over variables {ll,ii,jj} %%% summed over contributions {ii,ll,jj}
%                 end
%                 favar.HD.hd_estimates2{n+1,ii,jj}(1,kk)=favar.HD.HDinitial_estimates{jj,1}(ii,kk);
%                 if const==1
%                 favar.HD.hd_estimates2{n+2,ii,jj}(1,kk)=favar.HD.HDconstant_estimates{jj,1}(ii,kk);
%                 end
%                 if m>1
%                     favar.HD.hd_estimates2{n+3,ii,jj}(1,kk)=favar.HD.HDexo_estimates{jj,1}(ii,kk);
%                 end
%             end
%         end
% end
% 
% 
%     for jj=1:favar.npltX %for all factor variables
%     for ii=1:n %loop over variables (columns)
%     sumvariable = zeros(1,T+1);
%         for kk=1:T+1 %loop over periods
%             sumperiod=0; 
%             for ll=1:contributors %loop over contributors (rows)
%                 sumperiod = sumperiod+favar.HD.hd_estimates2{ll,ii,jj}(1,kk); 
%             end
%             sumvariable(1,kk)=sumperiod;
%         end 
%         favar.HD.HDsum{jj,1}(:,ii)=sumvariable(1,:);
%     end
%     end
%     
% % %% determine the unexplained part (if model is not fully identified) %%%%% does that mean IRF5?
%  aux = zeros(1,n);
% for jj=1:favar.npltX
%  favar.HD.unexplained{jj,1}=favar.X(lags+1:end,jj)-favar.HD.HDsum{jj,1}(2:end,:); %%%%% lags+1 is this right?
%  favar.HD.unexplained{jj,1}=[aux;favar.HD.unexplained{jj,1}];
% end
%     for jj=1:favar.npltX
%         for ii=1:n
%             favar.HD.hd_estimates2{contributors+1,ii,jj}=favar.HD.unexplained{jj,1}(:,ii)';
%         end
%     end
% 
% %% finally substract the sum of the contribution of the
% %exogenous, constant,initial conditions from Y to get the
% %part that was left to be explained by the shocks (for plotting reasons)
%  %Exosum = zeros(T+1,n); %if we sum over all variables this should give Y
%  for jj=1:favar.npltX
%     for ii=1:n %loop over variables (columns)
%         sumvariable = zeros(1,T+1);
%             for kk=1:T+1 %loop over periods
%                 sumperiod=0; 
%                     for ll=n+1:contributors %loop over contributors (rows)
%                         sumperiod=sumperiod+favar.HD.hd_estimates2{ll,ii,jj}(1,kk); 
%                     end
%                 sumvariable(1,kk)=sumperiod; 
%             end 
%         favar.HD.Exosum{jj,1}(:,ii)=sumvariable(1,:); 
%     end
%  end
%  %% determine the part that was left to be explained by the shocks
%  aux = zeros(1,n);
%  for jj=1:favar.npltX
%     favar.HD.tobeexplained{jj,1}=favar.X(lags+1:end,jj)-favar.HD.Exosum{jj,1}(2:end,:); %%%%% lags+1 is this right?
%     favar.HD.tobeexplained{jj,1}=[aux;favar.HD.tobeexplained{jj,1}];
%  end
%  for jj=1:favar.npltX
%     for ii=1:n
%         favar.HD.hd_estimates2{contributors+2,ii,jj}=favar.HD.tobeexplained{jj,1}(:,ii)';
%     end
%  end
% 
% %drop the initial entry for each cell in hd_estimates
% for jj=1:favar.npltX
%     for ii=1:n
%         for ll=1:contributors+2
%             favar.HD.hd_estimates{ll,ii,jj}=favar.HD.hd_estimates2{ll,ii,jj}(2:end);
%         end
%     end
% end
% end


%% FAVAR rescaling
if favar.FAVAR==1
if favar.pX==1
% % reorganize all for plotting
if favar.HD.sumShockcontributions==1
     for jj=1:favar.npltX %for all factor variables
         for ii=1:n %for variables
            for ll=1:n %for shock contributions         
               favar.HD.hd_estimates{ii,ll,jj}(1,:)=hd_estimates{ll,ii}(1,:)*favar.L(favar.plotX_index(jj,1),ii);%summed over variables {ll,ii,jj} %%% summed over contributions {ii,ll,jj}
            end
         end
             for ll=n+1:size(hd_estimates,1) %for the rest of the contributions
                for ii=1:n %for variables
                       favar.HD.hd_estimates{ll,ii,jj}(1,:)=hd_estimates{ll,ii}(1,:)*favar.L(favar.plotX_index(jj,1),ii);
                end
             end
     end
else               
     for jj=1:favar.npltX %for selected information variables
         for ii=1:n %for variables
            for ll=1:size(hd_estimates,1) %for shock contributions              
                favar.HD.hd_estimates{ll,ii,jj}(1,:)=hd_estimates{ll,ii}(1,:)*favar.L(favar.plotX_index(jj,1),ii);%summed over variables {ll,ii,jj} %%% summed over contributions {ii,ll,jj}
            end
         end
    end
end
end
end
% %%% contributors+1, contributors+2 are wrong here, adjust commented section
% favarHDsum=zeros(T,n); %if we sum over all variables this should give Y
% for jj=1:favar.npltX
%  for ii=1:n %loop over variables (columns)
%  sumvariable=zeros(1,T);
%  for kk=1:T %loop over periods
%      sumperiod=0; 
%   for ll=1:contributors %loop over contributors (rows)
%       sumperiod=sumperiod+favar.HD.hd_estimates{ll,ii,jj}(1,kk); 
%   end
%   sumvariable(1,kk)=sumperiod; 
%  end 
%  favarHDsum(:,ii,jj)=sumvariable(1,:);  %%%%% this should be Y?
%  end
% end
% end


% for qq=1:contributors %third dimension are contributions sumed over shockscontributions, %each column in contributions2 is the sum of all shock contributions, initvalues,etc to one endo variable
%     sumcontributions(:,:,qq)=sum(favar.HD.hd_estimates{1:contributors,qq:contributors2:end},2);
% end
% 
%             %sum shocks over third dimension of contributions (ii=1:n)
% for ll=1:identified
%                 contributions2(:,ll)=sumcontributions(:,1,ll);
% end


%  %% determine the unexplained part (if model is not fully identified) %%%%% does that mean in IRFt5???
% for jj=1:favar.npltX
%  aux=zeros(1,n);
%  unexplained = [aux; favar.X(:,favar.plotX_index(jj,1))-favarHDsum(:,:,jj)];
%     for ii=1:n
%     favar.HD.hd_estimates{contributors+1,ii,jj}=unexplained(:,ii)';
%     end
% end
 
%  %% finally substract the sum of the contribution of the (residual?)
% %exogenous, constant,initial conditions from Y to get the
% %part that was left to be explained by the shocks (for plotting reasons)
% favar_Exosum = zeros(T,n); %if we sum over all variables this should give Y
%  for jj=1:favar.npltX
%  for ii=1:n %loop over variables (columns)
%  sumvariable = zeros(1,T);
%  for kk=1:T %loop over periods
%      sumperiod=0; 
%   for ll=n+1:contributors %loop over contributors (rows)
%       sumperiod=sumperiod+favar.HD.hd_estimates{ll,ii,jj}(1,kk);
%   end
%   sumvariable(1,kk)=sumperiod;
%  end 
%  favar_Exosum(:,ii,jj)=sumvariable(1,:); 
%  end
%  end
%  
%   %% determine the part that was left to be explained by the shocks
% for jj=1:favar.npltX
%  aux=zeros(1,n);
%  tobeexplained=[aux; favar.X(:,favar.plotX_index(jj,:))-favar_Exosum(:,:,jj)];
% for ii=1:n
%     favar.HD.hd_estimates{contributors+2,ii,jj}=tobeexplained(:,ii)';
% end
% end
% for jj=1:favar.npltX
% %drop the initial entry for each cell in hd_estimates
% for ii=1:n % over variables
%     for ll=contributors:contributors+2 %all contributions
%         favar.HD.hd_estimates{ll,ii,jj}=favar.HD.hd_estimates{ll,ii,jj}(2:end);
%     end
% end
% end
%% plotting phase
if HD==1
%first get the contributions for fully identified models and plot them
if identified==n  
    if HDall==1 %if we want to plot all contributions
        % the actual value for each variable is given by Y
        Tobeexplained=Y'; 
    % loop over all contributors for all endogenous variable
    else %if we only want to plot the contributions of the shocks
        for ii=1:n
            Tobeexplained(ii,:)=hd_estimates{contributors+2,ii}(1:end);
        end
    end
else % for partially identified models
    for ii=1:n
        Unexplained(ii,:)=hd_estimates{contributors+1,ii}(1:end); 
    end
    if HDall==1 %if we want to plot all contributions
        % the actual value for each variable is given by Y
        Tobeexplained=Y';
    else
        for ii=1:n
            Tobeexplained(ii,:)=hd_estimates{contributors+2,ii}(1:end); 
        end
    end
end

%create labels for the contributions
if IRFt==1||IRFt==2||IRFt==3 
    labels=endo; % simply use the name of the endogenous variables as labels
elseif IRFt==5
     labels{identified,1}=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
elseif IRFt==4||IRFt==6
    labels=strctident.signreslabels_shocks; % signreslabels
end
    if HDall==1 % if all contributions are plotted add more labels
        labels{identified+1,1} = '*initvalues*';
        if const==1 && m>1
        labels{identified+2,1}='*constant*';
        labels{identified+3,1}='*exogenous*';
        elseif const==1 && m<=1
        labels{identified+2,1}='*constant*';
        elseif const==0 && m>=1
        labels{identified+2,1}='*exogenous*';
        end
        %labels{contributors+1,1}='*residual*'; %%% ????
     end

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

if pref.plot==1
for ii=1:n
hd=figure;
set(hd,'name','historical decomposition');

    clear contributions; 
    clear contribpos;
    clear contribneg;
    
    plothere=1;
    if HDall==1
    for jj=1:contributors
        if toplot(jj,1)==1
        contributions(:,plothere)=hd_estimates{jj,ii}(1:end);
        plothere=plothere+1;
        end 
    end
    else
    for jj=1:identified
        if toplot(jj,1)==1
            contributions(:,jj)=hd_estimates{jj,ii}(1:end);
            plothere=plothere+1;
        end
    end
    end
     %plothere=1;


% if identified==1 % do we need this case?
% bar(decimaldates1, contributions, 0.8, 'stacked');
% hold on
% plot(decimaldates1,Tobeexplained(ii,:),'k','LineWidth',0.2);
% axis tight
% hold off
% else
% distinguish between positive and negative values for plotting reasons
contribpos=contributions;
contribpos(contribpos<0)=0;
contribneg=contributions;
contribneg(contribneg>0)=0;
% plot positive values
bar(decimaldates1, contribpos,'stack');
hold on
plothd=gca;
plothd.ColorOrderIndex=1;
% plot negative values
bar(decimaldates1, contribneg,'stack');
hold on
% plot variable
plot(decimaldates1,Tobeexplained(ii,:), 'k');
axis tight
hold off
% end

% label the endogenous variables
title(endo{ii,1})
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
box off
hL=legend(labels);
LPosition = [0.47 0.00 0.1 0.1];
set(hL,'Position', LPosition, 'orientation', 'horizontal');
dim = [0.39 0.92 0.0 0.08];
annotation('textbox',dim,'String',' ','FitBoxToText','on','FontSize',8,'Linestyle','none');
%set(gcf,'PaperPositionMode','Auto')
legend boxoff
end
end

%% record in excel
hd_estimates = hd_estimates'; 
% create the cell that will be saved on excel
hdcell={};
% build preliminary elements: space between the tables
%horzspace=repmat({''},2,3*(identified+1));
vertspace=repmat({''},T+3,1);

% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
counter=0; %initiate counter
   % loop over shocks (horizontal dimension)
   for jj=1:identified
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
   temp=['contribution of ' labels{jj,1} ' shocks in ' endo{ii,1} ' fluctuation'];
   hd_ij=[temp {''} ;{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,jj})')];
   tempcell=[tempcell hd_ij vertspace];
   end
counter = identified;
% consider the contribution of initial conditions
temp=['contribution of initial conditions in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+1})')];
tempcell=[tempcell hd_ij vertspace];
%hdcell=[hdcell; horzspace; tempcell];
counter = counter+1;
% consider the contribution of the constant
if const==1
temp=['contribution of constant in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+2})')];
tempcell=[tempcell hd_ij vertspace];
counter = counter+1;
end


if m>1
    % consider the contribution of initial conditions
temp=['contribution of exogenous variables in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+3})')];
tempcell=[tempcell hd_ij vertspace];
counter = counter+1;
end 

% unexplained 
if identified<n
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
    bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),hdcell,'hist decomp','B2');
end
end


%% FAVAR block decomposition for information variables in X
if favar.HD.plot==1
        % plot X subsample of tranformationindex
        favar.HD.transformationindex_plotX=favar.transformationindex(favar.plotX_index,1);
        
    %first get the contributions for fully identified models and plot them
if identified==n
    if HDall==1 %if we want to plot all contributions
        % the actual value for each variable is given by Y
        for jj=1:favar.npltX %nblockindex
            favar.HD.HDTobeexplained_plotX{jj,1}=favar.X(lags+1:end,favar.plotX_index(jj,1));
        end
    elseif HDall==0 %if we only want to plot the contributions of the shocks only
        for jj=1:favar.npltX
            for ii=1:n
                favar.HD.HDTobeexplained_plotX{jj,1}(:,ii)=favar.X(lags+1:end,favar.plotX_index(jj,1));%favar.HD.hd_estimates{contributors+2,ii,jj}(1:end);
            end
        end
    end
else % how is case this different?
   for jj=1:favar.npltX
       for ii=1:n
            favar.HD.HDUnexplained_plotX{jj,1}(:,ii)=favar.X(lags+1:end,favar.plotX_index(jj,1));%favar.HD.hd_estimates{contributors+1,ii,jj}(1:end);
       end
   end
       if HDall==1
        for jj=1:favar.npltX %nblockindex
            favar.HD.HDTobeexplained_plotX{jj,1}=favar.X(lags+1:end,favar.plotX_index(jj,1));
        end
       elseif HDall==0
        for jj=1:favar.npltX
            for ii=1:n
                favar.HD.HDTobeexplained_plotX{jj,1}(:,ii)=favar.X(lags+1:end,favar.plotX_index(jj,1));%favar.HD.hd_estimates{contributors+2,ii,jj}(1:end);
            end
        end
   end
end
   
%create labels for the contributions
labelsX=favar.pltX; % plotX labels

%create labels for the contributions
if IRFt==1||IRFt==2||IRFt==3
    labelsfavar=endo; %simply use the name of the endogenous variables as labels
elseif IRFt==5
    labelsfavar{identified,1}=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
elseif IRFt==4||IRFt==6
    labelsfavar=strctident.signreslabels_shocks; % signreslabels
end
        % create more labels if we plott all the contributions
        if HDall==1 && favar.HD.HDallsumblock==0 %
        labelsfavar{identified+1,1} = '*initvalues*';
        if const==1 && m>1
        labelsfavar{identified+2,1}='*constant*';
        labelsfavar{identified+3,1}='*exogenous*';
        elseif const==1 && m<=1
        labelsfavar{identified+2,1}='*constant*';
        elseif const==0 && m>=1
        labelsfavar{identified+2,1}='*exogenous*';
        end
        labelsfavar{end+1,1} = '*residual*';
        end


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

if pref.plot==1
for jj=1:favar.npltX %loop over variables specified in plotX
    hdX=figure;
    set(hdX,'name',['historical decomposition of',' ',labelsX{jj}]);
    %% for now separate the routine for the IRFts here, check if they can be
    % merged
    if IRFt==1||IRFt==2||IRFt==3||IRFt==5
    clear contributions;
    clear contributions2;
    clear contributions3;
    clear contribpos;
    clear contribneg;
    clear out
    clear residual
        
    if HDall==1
        for ii=1:n
            plothere=1;
            for ll=1:contributors
                if toplot(ll,1)==1
                    contributions(:,plothere)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
                    plothere=plothere+1;
                end
                sumcontributions(:,ll,ii)=contributions(:,ll:contributors2:end);
            end
            % sum all contributions if we want to assign them to blocks
            if favar.HD.plotXblocks==1
                contributions2(:,ii)=sum(contributions,2);
            end
        end
        
    % rearrange contributions
    if favar.HD.plotXblocks==0
            %sum shocks over third dimension of contributions
             for ll=1:identified
                contributions2(:,ll)=sum(sumcontributions(:,:,ll),2);
             end
                % init values
                contributions2(:,identified+1)=sumcontributions(:,identified+1,1);
                % if we have a constant and exogenous
                if const==1 && m>1
                contributions2(:,identified+2)=sumcontributions(:,identified+2,1);
                contributions2(:,identified+3)=sumcontributions(:,identified+3,1);
                % if we have a constant
                elseif const==1 && m==1
                contributions2(:,identified+2)=sumcontributions(:,identified+2,1);
                elseif const==0 && m>1
                contributions2(:,identified+2)=sumcontributions(:,identified+3,1); % +3??? or +2?
                end

                 %%%% other transformation types?
                 if favar.transformation==1 | favar.plot_transform==1
                    if favar.HD.transformationindex_plotX(jj,1)==5
                        contributions2=exp(cumsum(contributions2))-1;
                        favar.HD.HDTobeexplained_plotX{jj,1}=exp(cumsum(favar.HD.HDTobeexplained_plotX{jj,1}))-1;
                    elseif favar.HD.transformationindex_plotX(jj,1)==4
                        contributions2=cumsum(contributions2);
                        favar.HD.HDTobeexplained_plotX{jj,1}=cumsum(favar.HD.HDTobeexplained_plotX{jj,1});
                    end
                 end
                residual=favar.HD.HDTobeexplained_plotX{jj,1}-sum(contributions2,2);
                contributions2=[contributions2,residual];

        % rearrange contributions for blocks
        elseif favar.HD.plotXblocks==1
               labelsfavar=endo; % initiate labels
               for ii=1:favar.nbnames 
                   out{ii,:}=favar.blocks_index{ii,1}(1,2:end); % entrys to drop
               end
               out=cat(2,out{:});
               
       if favar.HD.HDallsumblock==0
             for ll=1:identified
                contributions2(:,ll)=sum(sumcontributions(:,:,ll),2);
             end
        end

        for ii=1:favar.nbnames % rearange contributions blockwise
            contributions3{1,ii}=sum(contributions2(:,favar.blocks_index{ii,1}),2);
            contributions2(:,favar.blocks_index{ii,1}(1,1))=contributions3{1,ii};
        end
                %keep only blocks and Y variables, but add residual
                    contributions2(:,out)=[];
                        if favar.HD.HDallsumblock==0
                            contributions2=[contributions2,sumcontributions(:,identified+1,1)];
                            if const==1 && m>1
                            contributions2=[contributions2,sumcontributions(:,identified+2,1)];
                            contributions2=[contributions2,sumcontributions(:,identified+3,1)];
                            elseif const==1 && m==1
                            contributions2=[contributions2,sumcontributions(:,identified+2,1)];
                            elseif const==0 && m>1
                            contributions2=[contributions2,sumcontributions(:,identified+3,1)]; % +3??? or +2?
                            end
                        end
                    
                 %%%% other transformation types?
                 if favar.transformation==1 | favar.plot_transform==1
                    if favar.HD.transformationindex_plotX(jj,1)==5
                        contributions2=exp(cumsum(contributions2))-1;
                        favar.HD.HDTobeexplained_plotX{jj,1}=exp(cumsum(favar.HD.HDTobeexplained_plotX{jj,1}))-1;
                    elseif favar.HD.transformationindex_plotX(jj,1)==4
                        contributions2=cumsum(contributions2);
                        favar.HD.HDTobeexplained_plotX{jj,1}=cumsum(favar.HD.HDTobeexplained_plotX{jj,1});
                    end
                 end
                residual=favar.HD.HDTobeexplained_plotX{jj,1}-sum(contributions2,2);
                contributions2=[contributions2,residual];
                % label adjustments
                labelsfavar(out,:)=[];
                labelsfavar=erase(labelsfavar,'.factor1');

                if favar.HD.HDallsumblock==0
                labelsfavar=[labelsfavar;'*initvalues*'];
                        if const==1 && m>1
                        labelsfavar=[labelsfavar;'*constant*'];
                        labelsfavar=[labelsfavar;'*exogenous*'];
                        elseif const==1 && m==1
                        labelsfavar=[labelsfavar;'*constant*'];
                        elseif const==0 && m>=1
                        labelsfavar=[labelsfavar;'*exogenous*'];
                        end
                end
                labelsfavar=[labelsfavar;'*residual*'];
        end

        
    elseif HDall==0
        for ii=1:n
            plothere=1;
            for ll=1:identified
                if toplot(ll,1)==1
                    contributions(:,plothere)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
                    plothere=plothere+1;
                end

            end
                contributions2(:,ii)=sum(contributions,2);
        end
        
    % rearrange contributions
    if favar.HD.plotXblocks==0

            % transformation type adjustment, other types?
            if favar.HD.transformationindex_plotX(jj,1)==5
                contributions2=cumsum(contributions2);
                favar.HD.HDTobeexplained_plotX{jj,1}=cumsum(favar.HD.HDTobeexplained_plotX{jj,1});
            end
            
        % rearrange contributions for blocks
    elseif favar.HD.plotXblocks==1
                % rearrange contributions for blocks
               labelsfavar=endo; % initiate labels
               for ii=1:favar.nbnames 
                   out{ii,:}=favar.blocks_index{ii,1}(1,2:end); % entrys to drop
               end
               out=cat(2,out{:});

        for ii=1:favar.nbnames % rearange contributions blockwise
            contributions3{1,ii}=sum(contributions2(:,favar.blocks_index{ii,1}),2);
            contributions2(:,favar.blocks_index{ii,1}(1,1))=contributions3{1,ii};
        end
                %keep only blocks and Y variables
                contributions2(:,out)=[];
                % label adjustments
                labelsfavar(out,:)=[];
                labelsfavar=erase(labelsfavar,'.factor1');
        end
    end
    %% IRFt==4||IRFt==6
    elseif IRFt==4||IRFt==6
    clear contributions;
    clear contributions2;
    %clear contributions3;
    clear sumcontributions;
    clear contribpos;
    clear contribneg;
    clear residual

    if HDall==1
        for ii=1:n
            plothere=1; 
            for ll=1:contributors
                if toplot(ll,1)==1
                    contributions(:,plothere)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
                    plothere=plothere+1;
                end
            end
        end
        
      %%%sum contributions shockwise and separte initvalues etc?
    
    for qq=1:contributors2 %third dimension are contributions sumed over shockscontributions, %each column in contributions2 is the sum of all shock contributions, initvalues,etc to one endo variable
        sumcontributions(:,:,qq)=sum(contributions(:,qq:contributors2:end),2);
    end

%sum shocks over third dimension of contributions (ii=1:n)

             for ll=1:identified
                contributions2(:,ll)=sumcontributions(:,1,ll);
             end

                %if favar.HD.plotXblocks==0
                contributions2(:,identified+1)=sumcontributions(:,1,identified+1);
                if const==1 && m>1
                contributions2(:,identified+2)=sumcontributions(:,1,identified+2);
                contributions2(:,identified+3)=sumcontributions(:,1,identified+3);
                elseif const==1 && m<1
                contributions2(:,identified+2)=sumcontributions(:,1,identified+2);
                elseif const==0 && m>1
                contributions2(:,identified+2)=sumcontributions(:,1,identified+3); % +3??? or +2?
                end
                %end
                 %%%% other transformation types?
                 if favar.transformation==1 | favar.plot_transform==1
                    if favar.HD.transformationindex_plotX(jj,1)==5
                        contributions2=exp(cumsum(contributions2))-1;
                        favar.HD.HDTobeexplained_plotX{jj,1}=exp(cumsum(favar.HD.HDTobeexplained_plotX{jj,1}))-1;
                    elseif favar.HD.transformationindex_plotX(jj,1)==4
                        contributions2=cumsum(contributions2);
                        favar.HD.HDTobeexplained_plotX{jj,1}=cumsum(favar.HD.HDTobeexplained_plotX{jj,1});
                    end
                 end
                residual=favar.HD.HDTobeexplained_plotX{jj,1}-sum(contributions2,2);
                contributions2=[contributions2,residual];
    %end
        
        
    elseif HDall==0
        for ii=1:n %%%%% identified or n: contributions from identified shocks only? or over all shock contributions?
        for ll=1:identified %is this contributers?
            if toplot(ll,1)==1
               contributions(:,ll)=favar.HD.hd_estimates{ll,ii,jj}(1:end);
            end
        end
                
        end
    end
    end
    
%% save them to store them in excel
contributions2_all{jj,1}=contributions2;
labelsfavar_all=labelsfavar;
% if identified==1
% hdX=bar(decimaldates1,contributions2,0.8,'stacked');
% hold on
% plot(decimaldates1,favar.HD.HDTobeexplained_plotX{jj,1}(:,1),'k','LineWidth',0.2);
% axis tight
% hold off
%else %identified=n fully identified
% distinguish between positive and negative values for plotting
contribpos=contributions2;
contribpos(contribpos<0)=0;
contribneg=contributions2;
contribneg(contribneg>0)=0;
% plot positive values
bar(decimaldates1,contribpos,'stack');
hold on
plothd=gca;
plothd.ColorOrderIndex=1;
% plot negative values
bar(decimaldates1,contribneg,'stack');
hold on
% plot variable
plot(decimaldates1,favar.HD.HDTobeexplained_plotX{jj,1}(:,1),'k','LineWidth',0.2);
axis tight
hold off
%end

title(labelsX{jj,1})
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
box off
hL=legend(labelsfavar);
LPosition=[0.47 0.00 0.1 0.1];
set(hL,'Position',LPosition,'orientation','horizontal');
dim=[0.39 0.92 0.0 0.08];
annotation('textbox',dim,'String',' ','FitBoxToText','on','FontSize',8,'Linestyle','none');
%set(gcf,'PaperPositionMode','Auto')
legend boxoff
end
end

%% record in excel
% create the cell that will be saved on excel
hdcell_plotX={};
% build preliminary elements: space between the tables
%horzspace=repmat({''},2,3*(identified+1));
%counter
vertspace=repmat({''},T+2,1);
% loop over variables (vertical dimension)
for jj=1:favar.npltX
tempcell={};
counter=0; %initiate counter
   % loop over shocks (horizontal dimension)
   for ii=1:size(contributions2_all{jj},2)
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
   temp=['contribution of ' labelsfavar_all{ii,1} ' shocks in ' favar.pltX{jj,1} ' fluctuation'];
   hd_ij=[temp {''} ;{''} {''};stringdates1 num2cell((contributions2_all{jj}(:,ii)))];
   tempcell=[tempcell hd_ij vertspace];
   end
counter=size(contributions2_all{jj},2);
horzspace=repmat({''},2,3*(counter));
hdcell_plotX=[hdcell_plotX; horzspace; tempcell];
end
% trim
hdcell_plotX=hdcell_plotX(1:end,1:end-1);
% write in excel
if pref.results==1
    bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),hdcell_plotX,'hist decomp FAVAR','B2');
end
end
  
    