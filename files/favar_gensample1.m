function [informationstartlocation,informationendlocation,favar]=favar_gensample1(startdate,enddate,favar)
% information data table
[informationdata,informationnames]=xlsread('data.xlsx','factor data');
% also here: now, as a preliminary step: check if there is any Nan in the data; if yes, return an error since the model won't be able to run with missing data
% a simple way to test for NaN is to check for "smaller or equal to infinity": Nan is the only number for which matlab will return 'false' when asked so
informationdata2=informationdata(4:end,1:end);
% data transformation index (following Stock & Watson)
favar.transformationindex=informationdata(1,1:end)';
% identify the informationaldata date strings
favar.informationdatestrings=informationnames(4:end,1); %starts in line 4
% identify the informationaldata variable strings
favar.informationvariablestrings=informationnames(3,2:end); %starts in line 3

[r,c]=size(informationdata2);
for ii=1:r
    for jj=1:c
        temp=informationdata2(ii,jj);
        if (temp<=inf)==0
            % identify the variable and the date
            NaNvariable=favar.informationvariablestrings{1,jj};
            NaNdate=favar.informationdatestrings{ii,1};
            message=['Error: variable ' NaNvariable ' at date ' NaNdate ' (and possibly other sample entries) is identified as NaN. Please check your Excel factor data spreadsheet: entry may be blank or non-numerical.'];
            msgbox(message);
            error('programme termination: data error');
        end
    end
end


% identify the position of the string corresponding to the start period
favar.informationstartlocation=find(strcmp(favar.informationdatestrings,startdate)); %startdate specified in settings file, identical for the data sheet
% identify the position of the string corresponding to the end period
favar.informationendlocation=find(strcmp(favar.informationdatestrings,enddate)); %enddate specified in settings file, identical for the data sheet
informationendlocation=favar.informationendlocation;
% check transformation codes following Stock & Watson (2016)
if ~isempty(favar.transformationindex)
    % plotting is sensitve to transformation codes: this option is useful if
    % the data is already tranformed and favar.transformation=0
    favar.plot_transform=1;
    
    % create transformation type subsamples
    favar.transformation1=find(favar.transformationindex==1);
    favar.transformation2=find(favar.transformationindex==2);
    favar.transformation3=find(favar.transformationindex==3);
    favar.transformation4=find(favar.transformationindex==4);
    favar.transformation5=find(favar.transformationindex==5);
    favar.transformation6=find(favar.transformationindex==6);
    favar.transformation7=find(favar.transformationindex==7);
    
    % if factor data in excel is not transformed yet
    if favar.transformation==1
        %adjust sample to transformation
        if ~isempty(favar.transformation6)||~isempty(favar.transformation3)
            % second differences
            informationstartlocation=favar.informationstartlocation-2;
            favar.informationendlocation=informationendlocation-2;
        elseif ~isempty(favar.transformation5)||~isempty(favar.transformation2)
            % first differences
            informationstartlocation=favar.informationstartlocation-1;
            favar.informationendlocation=informationendlocation-1;
        else
            informationstartlocation=favar.informationstartlocation;
            favar.informationendlocation=informationendlocation;
        end
    else
        informationstartlocation=favar.informationstartlocation;
        favar.informationendlocation=informationendlocation;
    end
    
else % no transformation
    favar.plot_transform=0;
end

% if either the start date or the date date is not recognised, return an error message
if isempty(informationstartlocation)
    msgbox('Error: unknown start date for the factor data sample. Please check your sample start date (remember that names are case-sensitive).');
    error('programme termination: date error');
elseif isempty(favar.informationendlocation)
    msgbox('Error: unknown end date for the factor data sample. Please check your sample end date (remember that names are case-sensitive).');
    error('programme termination: date error');
end
% also, if the start date is posterior to the end date, obviously return an error
if informationstartlocation>=favar.informationendlocation==1
    msgbox('Error: inconsistency between the start and end dates. The start date must be anterior to the end date.');
    error('programme termination: date error');
end

% number of information variables
favar.nfactorvar=size(informationdata2,2);

% check if the startdate is in line with the transformation (1st, 2nd differences)
if informationstartlocation<1
    msgbox('Error: check if the startdate is consistent with the transformation types of the data set (first (2 & 5), second (3 & 6) differences).','startdate error','error','error');
    error('programme termination: startdate error');
end

% creation of favar.informationdata, sensitive to adjusted startdate
informationdata2=informationdata2(informationstartlocation:end,:);
% check if we have NaNs, and replace the NaNs with estimates
if sum(isnan(informationdata2(:)))>0
    msgbox('"factor data" sheet contains NaNs which will be replaced with estimates.','Detected NaNs','warn','warning');
    % % estimates values to replace NaNs
    % [coeff1,score1,~,~,~,mu1] = pca(informationdata2,'algorithm','als');
    % informationdata2=score1*coeff1'+repmat(mu1,size(informationdata2,1),1);
    %informationdata2=fillmissing(informationdata2,'movmedian',24);
    informationdata2=fillmissing(informationdata2,'linear');
    %informationdata2=fillmissing(informationdata2,'spline');
end

% tranformation of data following Stock & Watson (2016)
if favar.transformation==1
    for ii=1:favar.nfactorvar
        favar.informationdata(:,ii)=favar_transx(informationdata2(:,ii),favar.transformationindex(ii,1));
    end
    
    % remove NaNs: adjust sample to transformation
    % second differences
    if ~isempty(favar.transformation6)||~isempty(favar.transformation3)
        favar.X=favar.informationdata(1+2:end,:);
        % first differences
    elseif ~isempty(favar.transformation5)||~isempty(favar.transformation2)
        favar.X=favar.informationdata(1+1:end,:);
    else
        favar.X=favar.informationdata;
    end
else
    favar.X=informationdata2;
end

% recalculate informationendlocation for the cut sample
favar.informationendlocation_sub=favar.informationendlocation-informationstartlocation+1;

% before all the transformations, save standard deviations of information variables in X for rescaling
favar.X_stddev=std(favar.X(1:favar.informationendlocation_sub,:));

%%  The information variables X are demeaned and standardised and principal components XZ are calculated
% demean information data
[favar.X]=favar_demean(favar.X);
% save demeaned data before standardising
favar.X_temp=favar.X;

% standardise information data
[favar.X]=favar_standardise(favar.X);

%% extract factors
if favar.blocks==1 % categories: for example slow/fast moving variables BBE (2005)
    favar.blockindex=informationnames(2,2:end)';
    favar.nbnames=size(favar.bnames,1); % number of blocks
    % create indices for each block
    for ii=1:favar.nbnames % for all blocks
        for jj=1:favar.nfactorvar % for all information variables
            favar.blockindex_each{ii,1}(jj,1)=strcmp(favar.blockindex{jj},favar.bnames{ii})==1;
        end
    end
    
    % create block specfic data sets
    for ii=1:favar.nbnames
        favar.X_block{ii,1}=favar.X(:,favar.blockindex_each{ii,1});
    end
    
    % create block specific PC factors of X and specific numPC per block
    for ii=1:favar.nbnames
        [l,~,~,~,explained] = pca(favar.X_block{ii,1}, 'NumComponents',favar.bnumpc{ii,1});
        %identify factors: normalise loadings, compute factors following BBE 2005
        l=sqrt(size(favar.X_block{ii,1},2))*l;
        XZ=favar.X_block{ii,1}*l/size(favar.X_block{ii,1},2);
        % save the full sample (for forecast)
        favar.XZ_block_full{ii,1}=XZ;
        favar.X_block_full{ii,1}=favar.X_block{ii,1};
        % percent variability explained by principal components
        favar.bvariaexpl{ii,1}=explained(1:favar.bnumpc{ii,1},1);
        favar.bsumvariaexpl{ii,1}=sum(favar.bvariaexpl{ii,1});
        %save the loadings
        favar.l_block{ii,1}=l;
        
        % creation of favar.informationdata, sensitive to adjusted startdate and enddate
        favar.XZ_block{ii,1}=XZ(1:favar.informationendlocation_sub,:);
        favar.X_block{ii,1}=favar.X_block{ii,1}(1:favar.informationendlocation_sub,:);
    end
    favar.X_temp=favar.X_temp(1:favar.informationendlocation_sub,:);
    favar.X_full=favar.X;
    favar.X=favar.X(1:favar.informationendlocation_sub,:);
    % add block specific factor labels
    for jj=1:favar.nbnames
        for ii=1:favar.bnumpc{jj,1}
            favar.factorlabels_blocks{jj,ii}=sprintf('%s.factor%d',favar.bnames{jj,1},ii);
        end
    end
    
elseif favar.blocks==0 && favar.onestep==0 % special case for this case, the first block must be the block ordered first (slow) in the recursive scheme, it will crash with more than 2 blocks
    if favar.slowfast==1 %compute factors of slow-moving variables in this case
        favar.blockindex=informationnames(2,2:end)';
        favar.nbnames=size(favar.bnames,1); % number of blocks
        % create indices for each block
        for ii=1:favar.nbnames % for all blocks
            for jj=1:favar.nfactorvar % for all information variables
                favar.blockindex_each{ii,1}(jj,1)=strcmp(favar.blockindex{jj},favar.bnames{ii})==1;
            end
        end
        
        % create block specfic data sets
        for ii=1:favar.nbnames
            favar.X_block{ii,1}=favar.X(:,favar.blockindex_each{ii,1});
        end
        % static principal factors from the slow block
        [favar.l_slow]=pca(favar.X_block{1,1},'NumComponents',favar.numpc);
        %identify factors: normalise loadings, compute factors following BBE 2005
        favar.l_slow=sqrt(size(favar.X_block{1,1},2))*favar.l_slow;
        favar.XZ_slow=favar.X_block{1,1}*favar.l_slow/size(favar.X_block{1,1},2);
        
        favar.XZ_slow_full=favar.XZ_slow;
        favar.XZ_slow=favar.XZ_slow(1:favar.informationendlocation_sub,:);
    end
    
    % static principal factors from all the factordata
    [favar.l,~,~,~,favar.variaexpl]=pca(favar.X,'NumComponents',favar.numpc);
    favar.sumvariaexpl=sum(favar.variaexpl(1:favar.numpc,1)); % the percentage of the total variance explained by all principal components
    % add factor labels
    for ii=1:favar.numpc
        favar.factorlabels{1,ii}=sprintf('factor%d',ii);
    end
    %identify factors: normalise loadings, compute factors following BBE 2005
    favar.l=sqrt(favar.nfactorvar)*favar.l;
    favar.XZ=favar.X*favar.l/favar.nfactorvar;
    
    % save the full sample (for forecast) and cut the sample to the specified length
    favar.XZ_full=favar.XZ;
    favar.X_full=favar.X;
    
    % creation of favar.informationdata, sensitive to adjusted startdate and enddate
    favar.XZ=favar.XZ(1:favar.informationendlocation_sub,:);
    favar.X=favar.X(1:favar.informationendlocation_sub,:);
    favar.X_temp=favar.X_temp(1:favar.informationendlocation_sub,:);
    
elseif favar.blocks==0 % basic favar model without blocks
    % static principal factors from the factordata
    [favar.l,~,~,~,favar.variaexpl]=pca(favar.X,'NumComponents',favar.numpc);
    favar.sumvariaexpl=sum(favar.variaexpl(1:favar.numpc,1)); % the percentage of the total variance explained by all principal components
    % add factor labels
    for ii=1:favar.numpc
        favar.factorlabels{1,ii}=sprintf('factor%d',ii);
    end
    %identify factors: normalise loadings, compute factors following BBE 2005
    favar.l=sqrt(favar.nfactorvar)*favar.l;
    favar.XZ=favar.X*favar.l/favar.nfactorvar;
    
    % save the full sample (for forecast) and cut the sample to the specified length
    favar.XZ_full=favar.XZ;
    favar.X_full=favar.X;
    
    % creation of favar.informationdata, sensitive to adjusted startdate and enddate
    favar.XZ=favar.XZ(1:favar.informationendlocation_sub,:);
    favar.X=favar.X(1:favar.informationendlocation_sub,:);
    favar.X_temp=favar.X_temp(1:favar.informationendlocation_sub,:);
end

% plot selection of information variables (plotX)
% check for empty columns in signrestable
count=0;
for ii=1:size(favar.pltX,2)
    pltXcat=cat(2,favar.pltX{:,ii});
    if isempty(pltXcat)==0
        count=count+1;
    end
end

if count~=0
    favar.npltX=size(favar.pltX,1); % number of selected variables
    favar.pX=1; % to activate routines in IRF and HD
    % create indices for plotX variables
    for jj=1:favar.npltX
        for ii=1:favar.nfactorvar
            plotX_indexlogical{jj,1}(ii,1)=strcmp(favar.informationvariablestrings(1,ii),favar.pltX{jj,1});
        end
    end
    % position of pltX variables in X
    for jj=1:favar.npltX
        favar.plotX_index(jj,1)=find(plotX_indexlogical{jj,1}==1);
    end
    % % % elseif favar.HD.plotXblocks==1
    % % %     favar.pX=1; % to activate routines for specific cases in HD
else
    favar.npltX=0;
    favar.IRF.npltXshck=0;
    favar.plotX_index=[];
    favar.IRF.plot=0;
    favar.FEVD.plot=0;
    favar.HD.plot=0;
    favar.pX=0;
    favar.HD.plotXblocks=0;
end