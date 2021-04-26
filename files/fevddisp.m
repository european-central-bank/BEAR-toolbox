function []=fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar)



% function []=fevddisp(n,endo,IRFperiods,fevd_estimates,datapath)
% plots the results for the forecast error variance decomposition
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - integer 'IRFperiods': number of periods for IRFs
%          - cell 'fevd_estimates': lower bound, point estimates, and upper bound for the FEVD
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none

% fevd_estimates records variable 1 in row 1, variable 2 in row 2 etc
% records shock 1 in column 1, shock 2 in column 2 etc
% as in the Excel output
% number of identified shocks & create labels for the contributions
if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
    labels=endo;
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
    labels=strctident.signreslabels_shocks; % signreslabels
elseif IRFt==5
    identified=1; % one IV shock
    labels=strcat('IV Shock (',strctident.Instrument,')'); % and generate the sign res label here
end
% a custom colormap
myC=[
    0 0.4470 0.7410;     %blue
    0.8500 0.3250 0.0980; %orange
    0.9290 0.6940 0.1250; %yellow
    0.4940 0.1840 0.5560; %purple
    0.4660 0.6740 0.1880; %green
    0.3010 0.7450 0.9330; %cyan
    0.6350 0.0780 0.1840; %dark red
    0       0       1   ; %other blue
    0       1       0   ; %light green
    1       0       1   ; %pink
    1       1       0   ; %light yellow
    0       1       1   ; %
    1       1       1   ; %
    0.7 0.7 0.7];         %

contributions = NaN(n,n,IRFperiods);    % reports the median variance contribution of shock col1 to variable row1
for rrr = 1:n       % loops over rows i.e. variables
    for ccc = 1:n%identified   % loops over columns i.e. shocks
        contributions(rrr,ccc,:) = fevd_estimates{rrr,ccc}(2,:);     % 2 picks the median
    end
    if verLessThan('matlab','9.1') == 0
        aux = sum(contributions(rrr,:,:));
        contributions(rrr,:,:) = contributions(rrr,:,:)./aux*100;
    else
        msgbox('Error: FEVD requires Matlab version 2016b or higher');
    end
end


% prelim for FAVAR
if favar.FAVAR==1
    if favar.FEVD.plot==1
        
        favar_fevd_estimates=favar.FEVD.favar_fevd_estimates;
        %favar_fevd_estimates=favar_fevd_estimates(:,favar.IRF.plotXshock_index);
        favar_contributions = NaN(favar.npltX,favar.IRF.npltXshck,IRFperiods);    % reports the median variance contribution of shock col1 to variable row1
        labels{end+1,1}='*residual*';
        
        for rr=1:favar.npltX      % loops over rows i.e. variables
            for cc=1:identified+1  % loops over columns i.e. shocks plus idiosyncratic residual
                favar_contributions(rr,cc,:)=favar_fevd_estimates{rr,cc}(2,:);     % 2 picks the median
            end
            if verLessThan('matlab','9.1') == 0
                aux = sum(favar_contributions(rr,:,:));
                favar_contributions(rr,:,:) = favar_contributions(rr,:,:)./aux*100;
            else
                msgbox('Error: FEVD requires Matlab version 2016b or higher');
            end
        end
    end
end
if FEVD==1
    if pref.plot==1
        ncolumns=ceil(n^0.5);
        nrows=ceil(n/ncolumns);
        FEVDfig=figure;
        set(FEVDfig,'Color',[0.9 0.9 0.9]);
        set(FEVDfig,'name','forecast error variance decomposition')
        
        for rrr=1:n % loop over rows, i.e. variables
            subplot(nrows,ncolumns,rrr);
            fevd=bar(1:IRFperiods,squeeze(contributions(rrr,:,:))', 0.8, 'stacked');%, 'FaceColor','flat'
%             if length(labels)>14
%                 colorm=jet;
%                 num=floor((size(colorm,1))/size(contributions,2));
%             else
%                 colorm=myC;
%                 num=1;
%             end
%             for kk=1:size(contributions,2)
%                 fevd(kk).FaceColor=colorm(kk*num,:);
%             end
            axis tight
            title(endo{rrr,1},'FontWeight','normal','Interpreter','latex');
        end
        hL=legend(labels);
        set(hL,'Position',[0.45 0.00 0.1 0.1],'Orientation','horizontal','Interpreter','latex');
        legend boxoff
    end % pref.plot
    
    % finally, record results in excel
    if pref.results==1
        excelrecord6
    end
end

%% FAVAR FEVDs
if favar.FAVAR==1
    if favar.FEVD.plot==1
        FEVDfig=figure;
        numcol=ceil(sqrt(favar.npltX)); % rounded square root of npltX, make the plot quadratic
        numrow=ceil(favar.npltX/numcol); % and the number of rows we need
        
        set(FEVDfig,'Color',[0.9 0.9 0.9]);
        set(FEVDfig,'name','approximate forecast error variance decomposition (FAVAR)')
        
        for rr =1:favar.npltX     % loops over rows i.e. variables
            subplot(numrow,numcol,rr);
            fevd=bar(1:IRFperiods,squeeze(favar_contributions(rr,:,:))', 0.8, 'stacked'); %% we could also adjust this to blocks, 'FaceColor','flat'
%             if length(labels)>14
%                 colorm=jet;
%                 num=floor((size(colorm,1))/size(favar_contributions,2));
%                 % colormap=hsv;
%                 % colormap=colorcube;
%             else
%                 colorm=myC;
%                 num=1;
%             end
%             for kk=1:size(favar_contributions,2)
%                 fevd(kk).FaceColor=colorm(kk*num,:);
%             end
%                         plothd=gca;
%             plothd.ColorOrderIndex=1;
            axis tight
            title(favar.informationvariablestrings{1,favar.plotX_index(rr)},'FontWeight','normal','Interpreter','latex');
        end
        
        hL=legend(labels);
        set(hL,'Position',[0.45 0.00 0.1 0.1],'Orientation','horizontal','Interpreter','latex');
        legend boxoff
    end
    
    % finally, save on excel
    if pref.results==1
        favar_excelrecord6
    end
    
end

