function [data,variablestrings,favar]=favar_gensample2(data1,endo,variablestrings,startlocation,lags,favar)

% identify endogenous variable data, excluding factors


% cut data1, variablestrings
endo_index=ismember(variablestrings,endo);

favar.data_exfactors=data1(:,endo_index);
variablestrings=variablestrings(:,endo_index);
% identify endogenous variable strings, excluding factors
favar.variablestrings_exfactors_index=ismember(endo,variablestrings);
% endo variables other than factors only
favar.variablestrings_exfactors=find(favar.variablestrings_exfactors_index==1);
% identify endogenous variable strings, factors only
favar.variablestrings_factorsonly_index=ismember(endo,variablestrings)==0;
% endo variables factors only
favar.variablestrings_factorsonly=find(favar.variablestrings_exfactors_index==0);

% check if we have endo variables other than factors at all
if isempty(favar.variablestrings_exfactors)==1
    factormodel=1; % pure factor model in this case
    favar.data_exfactors=[];
    variablestrings={''};
else
    factormodel=0; % normal FAVAR
end

if favar.onestep==1
    % variable indexnM indexes which draws of FY (data_endo) refer to the factors only
    indexnM=repmat(favar.variablestrings_factorsonly_index,1,lags);
    favar.indexnM=find(indexnM==1);
end

if favar.blocks==1
    for jj=1:favar.nbnames
        for ii=1:size(endo,1)
            %for ll=1:favar.bnumpc{jj,1}
            %blocks_indexlogical{jj,1}(ll,ii)=strcmp(endo{ii,1},favar.factorlabels_blocks{jj,ll});
            blocks_indexlogical{jj,1}(ii,1)=contains(endo{ii,1},[favar.bnames{jj,1} '.'])==1;
            %end
        end
        %blocks_indexlogical{jj,1}=sum(blocks_indexlogical{jj,1},1);
        favar.blocks_index{jj,1}=find(blocks_indexlogical{jj,1}==1);
    end
end

% tranformation of data following Stock & Watson (2016)
if favar.transformation==1 || favar.plot_transform==1 %second condition is determined in favar_gensample1
    favar.transformationindex_endo_temp=ones(size(favar.variablestrings_factorsonly))'; % first: ones, no transformation
    if ~isempty(favar.transform_endo) % check if specified in the settings
        % and generate transformation index
        favar.transformationindex_exfactors=cell2mat(favar.trnsfrm_endo);
        % check number of transformation codes for endo variables
        if size(favar.transformationindex_exfactors,1) > size(favar.data_exfactors,2)
        message='Too many inputs in favar.transform_endo. Number of inputs must equal the number of endogenous non-factor variables. Remember that the ordering follows the ordering in the "data" excel sheet.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
        end
        favar.transformationindex_endo_temp=[favar.transformationindex_exfactors' favar.transformationindex_endo_temp];
        
        if favar.transformation==1 && factormodel==0
            for ii=1:size(favar.variablestrings_exfactors,1)
                [favar.data_exfactors_transformed(:,ii)]=favar_transx(favar.data_exfactors(:,ii),favar.transformationindex_exfactors(ii,1));
            end
            % remove NaNs: adjust sample to transformation
            if ~isempty(favar.transformation6)||~isempty(favar.transformation3)
                % second differences
                favar.data_exfactors=favar.data_exfactors_transformed(1+2:end,:);
            elseif ~isempty(favar.transformation5)||~isempty(favar.transformation2)
                % first differences
                favar.data_exfactors=favar.data_exfactors_transformed(1+1:end,:);
            else
                favar.data_exfactors=favar.data_exfactors_transformed;
            end
        end
    else
        favar.data_exfactors_transformed=favar.data_exfactors;
    end
end

% adjust sample to startlocation endlocation
%favar.data_exfactors=favar.data_exfactors(startlocation:endlocation,:);
favar.data_exfactors=favar.data_exfactors(startlocation:end,:);

% before all the transformations, save standard deviations of data_exfactors for rescaling
favar.data_exfactors_stddev_temp=ones(size(favar.variablestrings_factorsonly))';
if factormodel==0
    data_exfactors_stddev_temp=std(favar.data_exfactors(1:favar.informationendlocation_sub,:));
elseif factormodel==1
    data_exfactors_stddev_temp=[];
end
favar.data_exfactors_stddev_temp=[data_exfactors_stddev_temp favar.data_exfactors_stddev_temp];

favar.transformationindex_endo=ones(size(endo,1),1);
favar.data_exfactors_stddev(1,favar.variablestrings_factorsonly)=1;


% demean
[favar.data_exfactors]=favar_demean(favar.data_exfactors);
% save demeaned data before standardising
favar.data_exfactors_temp=favar.data_exfactors;

% standardise data
[favar.data_exfactors]=favar_standardise(favar.data_exfactors);


% save the full sample (for forecast) and cut the sample to the specified
% length
favar.data_exfactors_full=favar.data_exfactors;
if factormodel==0
    % creation of favar.informationdata, sensitive to adjusted startdate and enddate
    favar.data_exfactors=favar.data_exfactors(1:favar.informationendlocation_sub,:);
    favar.data_exfactors_temp=favar.data_exfactors_temp(1:favar.informationendlocation_sub,:);
end

if favar.blocks==1
    favar.data=favar.data_exfactors;
    favar.data_full=favar.data_exfactors_full;
    for ii=1:favar.nbnames
        % augment data and variablestrings with factors
        favar.data=[favar.data favar.XZ_block{ii}];
        favar.data_full=[favar.data_full favar.XZ_block_full{ii}];
        variablestrings=[variablestrings favar.factorlabels_blocks{ii,:}];
    end
    data=favar.data;
else
    data=[favar.data_exfactors favar.XZ];
    favar.data_full=[favar.data_exfactors_full favar.XZ_full];
    variablestrings=[variablestrings favar.factorlabels{1,:}];
end

% delete the first empty string, we don't have endo variables other than
% factors
if factormodel==1
    variablestrings=variablestrings(2:end);
end

