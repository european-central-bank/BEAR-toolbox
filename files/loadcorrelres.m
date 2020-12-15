function [strctident,signreslabels]=loadcorrelres(strctident,names,startdate,enddate,lags,n,IRFt,favar)

signreslabels=strctident.signreslabels;
signreslabels_shocksindex=strctident.signreslabels_shocksindex;

if strctident.CorrelInstrument=="" && strctident.CorrelShock=="" %if  CorrelInstrument CorrelShock are empty then skip this part completly
    strctident.checkCorrelInstrumentShock=0; %there is nothing to check
    strctident.hbartext_CorrelInstrumentShock='';
else
% however if we have no sign, relmagn FEVD restrictions at all, but we have correl restrictions then generate them
if strctident.signres==0 && strctident.zerores==0 && strctident.magnres==0 && strctident.favar_signres==0 && strctident.favar_zerores==0 && strctident.favar_magnres==0 && strctident.relmagnres==0 && strctident.favar_relmagnres==0 && strctident.FEVDres==0 && strctident.favar_FEVDres==0
% loop over endogenous (columns)
for ii=1:n
   % give the generic name 'shock ii'
       if IRFt==6 && ii==1 % special case for the IV shock in IRFt==6
        signreslabels{ii,1}=strcat('IV Shock (',strctident.Instrument,')');
        signreslabels_shocksindex=[signreslabels_shocksindex; ii];
       else
           signreslabels{ii,1}=['shock ' num2str(ii)];
           if strctident.signrestableempty(ii)==0 % restrictions, however no label is found, count this column
           signreslabels_shocksindex=[signreslabels_shocksindex; ii];
           end
       end
end
% save the shock index to later determine the number of identified shocks
strctident.signreslabels_shocksindex=unique(signreslabels_shocksindex);
strctident.signreslabels_shocks=signreslabels(strctident.signreslabels_shocksindex);
strctident.signreslabels=signreslabels;
strctident.periods=[0;0]; % also provide some periods here to generate irfs
end


% check if we have IV correlation restrictions
[IVcorrel,txtcorrel]=xlsread('data.xlsx','IV');
checkCorrelInstrument_index=ismember(txtcorrel(1,2:end),strctident.CorrelInstrument);
checkCorrelShock_index=ismember(strctident.signreslabels,strctident.CorrelShock); %%%%% evt. change to strcmp loop

% check for correlation restrictions
    % when there is no shock with an extra instrument
if sum(checkCorrelShock_index)==0 && sum(checkCorrelInstrument_index)==0
    strctident.checkCorrelInstrumentShock=0; %there is nothing to check
    strctident.hbartext_CorrelInstrumentShock='';
    % warning if we found a CorrelShock only
elseif sum(checkCorrelShock_index)~=0 && sum(checkCorrelInstrument_index)==0
    strctident.checkCorrelInstrumentShock=0;
    strctident.hbartext_CorrelInstrumentShock='';
   message=['Found CorrelShock ' strctident.CorrelShock ', but CorrelInstrument ' strctident.CorrelInstrument ' cannot be found in the "IV" excel sheet. Correlation restrictions are ignored.'];
   msgbox(message,'Correlation restriction warning');
    % warning if we found a CorrelShock only
elseif sum(checkCorrelShock_index)==0 && sum(checkCorrelInstrument_index)~=0 && strcmp(strctident.CorrelShock,'CorrelShock')==0
    strctident.checkCorrelInstrumentShock=0;
    strctident.hbartext_CorrelInstrumentShock='';
   message=['Found CorrelInstrument ' strctident.CorrelInstrument ', but CorrelShock ' strctident.CorrelShock ' cannot be found. Correlation restrictions are ignored.'];
   msgbox(message,'Correlation restriction warning');
    % we found a CorrelInstrument and a CorrelShock
elseif sum(checkCorrelInstrument_index)~=0 && sum(checkCorrelShock_index)~=0 | strcmp(strctident.CorrelShock,'CorrelShock')==1
    % find index for the Shock with correlation restriction
    strctident.CorrelShock_index=find(checkCorrelShock_index); %save index
    strctident.checkCorrelInstrumentShock=1;   
    Index = strcmp(txtcorrel(1,:),strctident.CorrelInstrument);           %find the instrument in the IV sheet
    IVnum = find(Index==1, 1, 'first')-1;
    IVcorrel = IVcorrel(:, IVnum); 
    IVcorrel = IVcorrel(~isnan(IVcorrel));
    txtcorrel = txtcorrel(2:length(IVcorrel)+1,1);              % drop IV names from txt
    date = names(2:end,1);                                   %get the datevector of the VAR
    startlocationY_in_Y=find(strcmp(date,startdate));        %location of sample startdate in Y datevector
    endlocationY_in_Y=find(strcmp(date,enddate));            %location of sample enddate in Y datevector
    date = date(startlocationY_in_Y+lags:endlocationY_in_Y,:);  %cut datevector of Y such that it corresponds to the time dates used in the VAR
    strctident.OverlapIVcorrelinY = ismember(date,txtcorrel);           %Use this to cut EPS
    strctident.OverlapYinIVcorrel = ismember(txtcorrel,date);           %Use this to cut IV
    strctident.IVcorrel = IVcorrel(strctident.OverlapYinIVcorrel,:);               %cut all the entries from IV that are not in the sample
    strctident.hbartext_CorrelInstrumentShock='correlation, ';
    
    % check for empty other res shocks and non-empty correl res shocks
    correlshocktest=0;
    for ii=1:size(strctident.signreslabels,1)
        if correlshocktest==1
            break
        end
        if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==1 && strctident.favar_relmagnrestableempty(ii,1)==1 && strctident.FEVDrestableempty(ii,1)==1 && strctident.favar_FEVDrestableempty(ii,1)==1 && checkCorrelShock_index(ii,1)==0 && strcmp(strctident.CorrelShock,'CorrelShock')==1
        % add them to the list of identified shocks in this case
        strctident.signreslabels{ii,1}=['CorrelShock (' strctident.CorrelInstrument ')'];    % or generate a label
        strctident.signreslabels_shocksindex=[strctident.signreslabels_shocksindex; ii]; % add it in the shocksindex
        checkCorrelShock_index(ii,1)=1;
        correlshocktest=1;
        end
    end

% update the output in strctident
strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
signreslabels=strctident.signreslabels;
strctident.CorrelShock_index=find(checkCorrelShock_index);
    
%finally check if there are sign restrictions on the shock of interest. If
%not we can use the flipped entry of the rotation matrix aswell
    if ~isempty(strctident.CorrelShock)
    if isempty(strctident.Scell{1,strctident.CorrelShock_index})
    strctident.FlipCorrel=1;
    else
    strctident.FlipCorrel=0;
    end
    end
end
end

if favar.FAVAR==1
% check here if the shocks of interest actually exist
if favar.IRF.npltXshck > size(strctident.signreslabels_shocks,1)
        % error if no shock to plot is found, otherwise code crashes at a later stage
        message=['Error: Shock(s) (' favar.IRF.plotXshock ') cannot be found.'];
        msgbox(message,'favar.IRF.plotXshock');
        error('programme termination: favar.IRF.plotXshock error');
end
end