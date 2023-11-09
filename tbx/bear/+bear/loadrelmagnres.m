function [relmagnrestable,relmagnresperiods,signreslabels,strctident,favar]=loadrelmagnres(n,endo,pref,favar,IRFt,strctident)

% preliminary tasks

% initiate the cells relmagrestable and relmagresperiods
relmagnrestable = pref.data.RelMagnResValues;
relmagnrestable = relmagnrestable(contains(endo,relmagnrestable.Properties.RowNames), contains(endo, relmagnrestable.Properties.RowNames));
relmagnrestable = bear.utils.parseTableContent(relmagnrestable{:,:});
if isempty(relmagnrestable)
    relmagnrestable = repmat({[]},n,n);
end

% relmagnrestable= bear.utils.parseTableContent(pref.data.RelMagnResValues{:,2:end});
relmagnresperiods = cell(n,n);
signreslabels=strctident.signreslabels;
signreslabels_shocksindex=strctident.signreslabels_shocksindex;

%% check if relative magnitude restrictions are activated at all
% check for empty columns in relmagn res table
emptycells = cellfun(@isempty, relmagnrestable);
count=sum( any( ~emptycells ) );

if count==0 && favar.FAVAR==0 % we found no relmagn res (this test is not applicable to the favar restrictions)
    strctident.relmagnres=0;
    strctident.hbartext_relmagnres='';
    strctident.favar_relmagnres=0;
    strctident.hbartext_favar_relmagnres='';
    strctident.relmagnrestableempty=ones(n,1);
    strctident.favar_relmagnrestableempty=ones(n,1);
else % if we found something in the table then the relmagn routine is activated
    %% relative magnitude restriction values  

    % identify empty relmagn res table columns
    for ii=1:size(relmagnrestable,2)
        strctident.relmagnrestableempty(ii,1)=isempty(cat(2,relmagnrestable{:,ii}))==1;
    end

    % erase first column in the restriction table for IV shock
    if IRFt==6
        % check for empty columns in sign res table
        if strctident.relmagnrestableempty(1,1)==0
            for ll=1:size(relmagnrestable,1)
                relmagnrestable{ll,1}='';
            end
            signreslabels{1,1}=strcat('IV Shock (',strctident.Instrument,')');
            signreslabels_shocksindex(1,1)=1;
            message= "The restrictions in the first column of the ""relmagn res values"" table are ignored. This is the IV shock.";
            msgbox(message,'Relative magnitude restriction warning');
        end
    end
    %% relative magnitude restriction periods  
    relmagnresperiods = pref.data.RelMagnResPeriods;
    relmagnresperiods = relmagnresperiods(contains(endo,relmagnresperiods.Properties.RowNames), contains(endo, relmagnresperiods.Properties.RowNames));

    if height(relmagnresperiods) ~= n || width(relmagnresperiods) ~= n
        message = "Some endogenous variable cannot be found in both rows and columns of the table. Please verify that the ""FEVD res periods"" sheet of the Excel data file is properly filled.";
        error("bear:loadFEVDres:FEVDrestrictionError", message)
    end

    relmagnresperiods = bear.utils.parseTableContent(relmagnresperiods{:,:});    
    relmagnresperiods = cellfun(@str2num, relmagnresperiods, 'UniformOutput', false);

    % erase first column in the restriction table for IV shock
    if IRFt==6
        % check for empty columns in sign res table
        for ii=1:size(relmagnresperiods,2)
            relmagnresperiodscat=cat(2,relmagnresperiods{:,ii});
            if ii==1 && isempty(relmagnresperiodscat)==0
                for ll=1:size(relmagnresperiods,1)
                    relmagnresperiods{ll,ii}='';
                end
                message = "The restrictions in the first column of the ""relmagn res periods"" table are ignored. This is the IV shock.";
                msgbox(message,'Relative magnitude restriction warning');
            end
        end
    end

    % however if we have no sign restrictions at all, but we have rel magn restrictions then generate them from the "relmagn res values" table
    if strctident.signres==0 && strctident.zerores==0 && strctident.magnres==0 && strctident.favar_signres==0 && strctident.favar_zerores==0 && strctident.favar_magnres==0

        % loop over endogenous (columns)
        labels = pref.data.RelMagnResValues.Properties.VariableDescriptions;
        for ii=1:n
            temp = labels{ii};
            if IRFt==6 && ii==1 % special case for the IV shock in IRFt==6
                signreslabels{ii,1} = "IV Shock (" + strctident.Instrument + ")";
                signreslabels_shocksindex=[signreslabels_shocksindex; ii];
            elseif isempty(temp)
                signreslabels{ii,1} = "shock " + ii;
                if strctident.relmagnrestableempty(ii)==0 % restrictions, however no label is found, count this column
                    signreslabels_shocksindex=[signreslabels_shocksindex; ii];
                end
            else
                if strctident.relmagnrestableempty(ii)==0 % label and restictions found
                    signreslabels{ii,1}=temp;
                    signreslabels_shocksindex=[signreslabels_shocksindex; ii];
                elseif strctident.relmagnrestableempty(ii)==1 % label, however no restriction is found, ignore this column
                    signreslabels{ii,1} = "shock " + ii;
                end
            end
        end
           
        % save the shock index to later determine the number of identified shocks
        strctident.signreslabels_shocksindex=unique(signreslabels_shocksindex);
        strctident.signreslabels_shocks=signreslabels(strctident.signreslabels_shocksindex);
        strctident.signreslabels=signreslabels;
    end



    %% Preliminaries for relative magnitude restrictions
    % now identify all the periods concerned with relative magnitude
    % restrictions
    % first expand the non-empty entries in magresperiods since they are only expressed in intervals: transform into list
    % for instance, translate [1 4] into [1 2 3 4];
    temp=cell2mat(relmagnresperiods(~cellfun(@isempty,relmagnresperiods)));
    mperiods=[];
    for ii=1:size(temp,1)
        mperiods=[mperiods temp(ii,1):temp(ii,2)];
    end
    % suppress duplicates and sort
    strctident.mperiods=sort(unique(mperiods))';
    % count the total number of restriction periods (required for IRF matrix)
    %rmperiods=size(strctident.mperiods,1);

    %create matrix entry for relative magnitude restrictions
    [r] = find(~cellfun('isempty',relmagnrestable));
    %2. Indentify which entry corresponds to the positive magnitude
    %restriction (which shock is supposed to have a larger impact on which
    %variable)
    num_magres=length(r)/2; %number of relative magnitude restrictions

    strctident.rowsS = [];
    strctident.columnsS = [];
    for jj=1:num_magres %%loop over number of magnitude restrictions
        strtemp = strcat('S',num2str(jj)); %%find entry in the table corresponding to the Stronger than restriction
        Stronger = strcmp(relmagnrestable, strtemp);
        [rowS,columnS] = find(Stronger==1);
        strctident.rowsS = [strctident.rowsS rowS];
        strctident.columnsS = [strctident.columnsS columnS];
    end

    strctident.rowsW = [];
    strctident.columnsW = [];
    for jj=1:num_magres
        strtemp = strcat('W',num2str(jj));
        Weaker = strcmp(relmagnrestable, strtemp);
        [rowW,columnW] = find(Weaker==1);
        strctident.rowsW = [strctident.rowsW rowW];
        strctident.columnsW = [strctident.columnsW columnW];
    end

    % check number of W and S restrictions
    if size(strctident.columnsW,1)~=size(strctident.columnsS,1)
        strctident.relmagnres=0;
        strctident.hbartext_relmagnres='';
        message = "S and W restrictions are inconsistent. Relative magnitude restrictions are ignored.";
        msgbox(message,'Relative magnitude restriction warning');
    else

        % check for relative magnitude restrictions
        if isempty(strctident.columnsW)==0 && isempty(strctident.columnsS)==0
            strctident.relmagnres=1;
            strctident.hbartext_relmagnres='rel. magnitude, ';

            % check if shocks are not identified via sign res or favar sign res, but via relmagn res
            % check for empty signres, favar_signres and non-empty relmagn res shocks
            for ii=1:size(strctident.signreslabels,1)
                if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==0
                    % add them to the list of identified shocks in this case
                    if isempty(labels{ii})==0
                        strctident.signreslabels{ii,1}=labels{ii}; % take the label provided in the table in this case
                    else
                        strctident.signreslabels{ii,1}=['shock ' num2str(ii)];    % or generate a label
                    end
                    strctident.signreslabels_shocksindex=[strctident.signreslabels_shocksindex; ii]; % add it in the shocksindex
                end
            end
            % update the output in strctident
            strctident.signreslabels_shocksindex=unique(strctident.signreslabels_shocksindex);
            strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
            signreslabels=strctident.signreslabels;

        elseif isempty(strctident.columnsW)==1 && isempty(strctident.columnsS)==1 % we found no relmagn res
            strctident.relmagnres=0;
            strctident.hbartext_relmagnres='';
        end

    end

    %% FAVAR
    if favar.FAVAR==1
        % strings of restricted information variables
        % which information variables are restricted?
        Xsignres=ismember(pref.data.RelMagnResValues.Properties.RowNames,favar.informationvariablestrings);
        % number of restricted variables in X
        favar.nrelmagnresX=sum(Xsignres);
        % keep only the ones that are actually in X
        favar.relmagnresX=pref.data.RelMagnResValues.Properties.RowNames(Xsignres);
        if favar.nrelmagnresX==0
            favar.relmagnresX_index=[];
        end

        % % all rows that are not empty
        [Xnerows1index, ~] = find(~ismissing(pref.data.RelMagnResValues));
        % neclmns1index=neclmns1==1;
        % neclmns1index=nerows1(neclmns1index,1);
        % % nerows1indexend=find(nerows1index==rows(end,1));
        % % if nerows1indexend==size(nerows1index,1)
        % %     favar.nrelmagnresX=0;
        % %     favar.relmagnresX_index=[];
        % % else
        % % % only information variables in X that are restricted
        % Xnerows1index=nerows1index(size(rows,1)+1:end,1);

        % % strings of restricted information variables
        % favar.relmagnresX=strngs1(max(rows)+1:end,min(clmns)-1); %strngs1 is already adjusted for empty rows and columns
        % %number of restricted information variables
        % favar.nrelmagnresX=size(favar.relmagnresX,1);
        % end
        %create indices for restricted information variables (advantage here: ordering in the sign res table is irrelevant)
        for jj=1:favar.nrelmagnresX
            for ii=1:favar.nfactorvar
                favar.relmagnresX_indexlogical{jj,1}(ii,1)=strcmp(favar.informationvariablestrings(1,ii),favar.relmagnresX{jj,1});
            end
        end
        for jj=1:favar.nrelmagnresX
            favar.relmagnresX_index(jj,1)=find(favar.relmagnresX_indexlogical{jj,1});
        end

        favar.relmagnrestable=cell(favar.nrelmagnresX,n);
        % now recover the values for the cell favar.signrestable
        favar.relmagnrestable = cellstr(pref.data.RelMagnResValues{Xsignres, endo});
        % for ii=1:favar.nrelmagnresX % loop over restricted information variables
        %     for jj=1:n % loop over endogenous (columns)
        %         favar.relmagnrestable{ii,jj}=pref.data.RelMagnResValues{Xnerows1index(ii,1),clmns(jj,1)};
        %     end
        % end


        % identify empty relmagn res table columns
        for ii=1:size(favar.relmagnrestable,2)
            strctident.favar_relmagnrestableempty(ii,1)=isempty(cat(2,favar.relmagnrestable{:,ii}))==1;
        end


        % erase first column in the restriction table for IV shock
        if IRFt==6
            % check for empty columns in sign res table
            if strctident.relmagnrestableempty(1,1)==0
                for ll=1:size(favar.relmagnrestable,1)
                    favar.relmagnrestable{ll,1}='';
                end
                message= "The restrictions in the first column of the ""relmagn res values"" table are ignored. This is the IV shock.";
                msgbox(message,'Relative magnitude restriction warning');

            end
        end

        %assuming that the variables in the table here are identical to the variables in the sign res value table
        % now recover the values for the cell favar.signrestable
        favar.relmagnresperiods = cellstr(pref.data.RelMagnResPeriods{Xsignres, endo});

        % check if we have restrictions
        if sum(strctident.favar_relmagnrestableempty==0)~=0
            favar_temp=cell2mat(favar.relmagnresperiods(~cellfun(@isempty,favar.relmagnresperiods)));
            favar_mperiods=[];
            for ii=1:size(favar_temp,1)
                favar_mperiods=[favar_mperiods favar_temp(ii,1):favar_temp(ii,2)];
            end
            % if (favar_mperiods/2)~=favar.nrelmagnresX
            %       message=['The restrictions in the "relmagn res values" table do not correspond to the periods in "relmagn res periods".'];
            %       msgbox(message,'Relative magnitude restriction warning');
            %       error('programme termination: relative magnitude restriction error');
            % end
            % suppress duplicates and sort
            strctident.favar_mperiods=sort(unique(favar_mperiods))';
            % count the total number of restriction periods (required for IRF matrix)
            %favar_rmperiods=size(strctident.favar_mperiods,1); %%%%periods or mperiods here?

            %create matrix entry for relative magnitude restrictions
            [r] = find(~cellfun('isempty',favar.relmagnrestable)); % why is clm not used?
            %2. Indentify which entry corresponds to the positive magnitude
            %restriction (which shock is supposed to have a larger impact on which
            %variable)
            favar_num_magres=length(r)/2; %number of relative magnitude restrictions

            strctident.favar_rowsS=[];
            strctident.favar_columnsS=[];
            for jj=1:favar_num_magres %%loop over number of magnitude restrictions
                favar_strtemp=strcat('S',num2str(jj)+num_magres); %+num_magres
                Stronger=strcmp(favar.relmagnrestable,favar_strtemp);
                [favar_rowS,favar_columnS]=find(Stronger==1);
                strctident.favar_rowsS=[strctident.favar_rowsS favar_rowS];
                strctident.favar_columnsS=[strctident.favar_columnsS favar_columnS];
            end

            strctident.favar_rowsW=[];
            strctident.favar_columnsW=[];
            for jj=1:favar_num_magres
                favar_strtemp=strcat('W',num2str(jj)+num_magres); %+num_magres
                Weaker=strcmp(favar.relmagnrestable,favar_strtemp);
                [favar_rowW,favar_columnW]=find(Weaker==1);
                strctident.favar_rowsW=[strctident.favar_rowsW favar_rowW];
                strctident.favar_columnsW=[strctident.favar_columnsW favar_columnW];
            end

            % check number of W and S restrictions
            if size(strctident.favar_columnsW,1)~=size(strctident.favar_columnsS,1)
                strctident.favar_relmagnres=0;
                strctident.hbartext_favar_relmagnres='';
                message= "S and W restrictions (FAVAR) are inconsistent. Relative magnitude restrictions (FAVAR) are ignored.";
                msgbox(message,'Relative magnitude restriction warning');
            else
                % check for relative magnitude restrictions
                if isempty(strctident.favar_columnsW)==0 && isempty(strctident.favar_columnsS)==0
                    strctident.favar_relmagnres=1;
                    strctident.hbartext_favar_relmagnres='favar-rel. magnitude, ';

                    % check if shocks are not identified via sign res or favar sign res,relmagn res, but via favar relmagn res
                    % check for empty signres, favar_signres,relmagn res  and non-empty favar relmagn res shocks
                    for ii=1:size(strctident.signreslabels,1)
                        if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==1 && strctident.relmagnrestableempty(ii,1)==1 && strctident.favar_relmagnrestableempty(ii,1)==0
                            % add them to the list of identified shocks in this case
                            if isempty(strngs1{min(rows)-2,clmns(ii,1)})==0
                                strctident.signreslabels{ii,1}=strngs1{min(rows)-2,clmns(ii,1)}; % take the label provided in the table in this case
                            else
                                strctident.signreslabels{ii,1}=['shock ' num2str(ii)];    % or generate a label
                            end
                            strctident.signreslabels_shocksindex=[strctident.signreslabels_shocksindex; ii]; % add it in the shocksindex
                        end
                    end
                    % update the output in strctident
                    strctident.signreslabels_shocksindex=unique(strctident.signreslabels_shocksindex);
                    strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
                    signreslabels=strctident.signreslabels;

                    % create indices for plotXshock
                    if favar.IRFplot==1 && favar.npltX>0
                        IRFplotXshock_indexlogical=ismember(signreslabels,favar.IRF.pltXshck);
                        favar.IRF.plotXshock_index=find(IRFplotXshock_indexlogical==1)';
                        favar.IRF.npltXshck=size(favar.IRF.pltXshck,1);
                        if favar.IRF.npltXshck==0
                            % error if no shock to plot is found, otherwise code crashes at a later stage
                            message=['Error: at least one Shock (' favar.IRFplotXshock ') cannot be found.'];
                            error('bear:loadrelmagnres:ShockNotFound',message)
                        end
                    end
                    if favar.FEVDplot==1
                        FEVDplotXshock_indexlogical=ismember(signreslabels,favar.FEVD.pltXshck);
                        favar.FEVD.plotXshock_index=find(FEVDplotXshock_indexlogical==1)';
                        favar.FEVD.npltXshck=size(favar.FEVD.pltXshck,1);
                    end

                    % adjust periods in case the maximum number of restricted periods is larger for favar restrictions only
                    if max(strctident.favar_mperiods)>max(strctident.mperiods)
                        strctident.mperiods=strctident.favar_mperiods;
                    end


                elseif isempty(strctident.columnsW)==1 && isempty(strctident.columnsS)==1
                    strctident.favar_relmagnres=0;
                    strctident.hbartext_favar_relmagnres='';
                end
            end

        else % when no rel. mag res are found here
            strctident.favar_relmagnres=0;
            strctident.hbartext_favar_relmagnres='';
        end


    else %no favar
        strctident.favar_relmagnres=0;
        strctident.hbartext_favar_relmagnres='';
        strctident.favar_relmagnrestableempty=ones(n,1);
    end


    % finally, record on Excel
    if pref.results==1
        pref.exporter.writeRelMagnResValues(pref.data.RelMagnResValues)
        pref.exporter.writeRelMagnResperiods(pref.data.RelMagnResValues)
    end
end
